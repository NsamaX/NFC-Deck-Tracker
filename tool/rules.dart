const package = 'nfc_deck_tracker';

const allowedDomainPackages = {'equatable', 'uuid'};

const forbiddenDomainDartLibs = {'dart:io', 'dart:ui', 'dart:html'};

const infrastructurePackages = {
  'firebase_auth',
  'firebase_core',
  'cloud_firestore',
  'firebase_storage',
  'google_sign_in',
  'supabase_flutter',
  'sqflite',
  'shared_preferences',
  'get_it',
  'nfc_manager',
  'image_picker',
  'path_provider',
  'permission_handler',
  'connectivity_plus',
  'package_info_plus',
  'http',
};

enum ViolationKind {
  circular('circular-dep', 'Circular dependency', 'Critical',
      'Files that import each other directly or through a chain.'),
  domainOutward('domain-outward', 'Domain depends outward', 'Critical',
      'Domain may import only other domain files.'),
  domainSdk('domain-sdk', 'Domain depends on a framework', 'Critical',
      'Domain may import only `dart:` core libraries, equatable, and uuid.'),
  presentationBypass('presentation-bypass', 'Presentation bypasses use cases',
      'High',
      'Presentation must call use cases and entities, never data, composition, or repository ports.'),
  presentationSdk('presentation-sdk', 'Presentation uses an infrastructure SDK',
      'High',
      'Storage, auth, NFC, and device SDKs belong in data adapters behind domain ports.'),
  dataUpward('data-upward', 'Data depends on presentation or composition',
      'Medium', 'Data implements domain ports and must not know its callers.');

  final String slug;
  final String label;
  final String severity;
  final String description;

  const ViolationKind(this.slug, this.label, this.severity, this.description);
}

class Violation {
  final ViolationKind kind;
  final String detail;

  const Violation(this.kind, [this.detail = '']);

  static const circular = Violation(ViolationKind.circular);

  String get slug => kind.slug;
  String get label => kind.label;
}

class Dependency {
  final String target;
  final bool isInternal;

  const Dependency(this.target, this.isInternal);
}

final _directive = RegExp(
  r'''^\s*(import|export|part(?:\s+of)?)\s+([^;]+);''',
  multiLine: true,
);
final _uri = RegExp(r'''['"]([^'"]+)['"]''');

Iterable<Dependency> dependencies(String source, String rel) sync* {
  final base = Uri.parse('lib/$rel');
  for (final directive in _directive.allMatches(source)) {
    if (directive.group(1)!.startsWith('part of')) continue;
    for (final uri in _uri.allMatches(directive.group(2)!)) {
      final raw = uri.group(1)!;
      if (raw.startsWith('package:$package/')) {
        yield Dependency(raw.substring('package:$package/'.length), true);
      } else if (raw.contains(':')) {
        yield Dependency(raw, false);
      } else {
        yield Dependency(base.resolve(raw).toString().substring(4), true);
      }
    }
  }
}

String layerOf(String rel) {
  final first = rel.split('/').first;
  switch (first) {
    case 'domain':
    case 'data':
    case 'presentation':
    case 'util':
      return first;
    case '.config':
      return 'config';
    case '.injector':
      return 'injector';
    default:
      return 'root';
  }
}

String? roleOf(String rel) {
  final parts = rel.split('/');
  if (parts.length < 3) return null;
  switch (parts[0]) {
    case 'domain':
      return switch (parts[1]) {
        'repository' => 'port',
        'usecase' => 'usecase',
        'entity' => 'entity',
        _ => parts[1],
      };
    case 'data':
      if (parts[1] == 'datasource' && parts.length > 3) {
        return 'datasource-${parts[2]}';
      }
      return parts[1];
    case 'presentation':
      return parts[1];
  }
  return null;
}

String? entryOf(String rel) {
  final name = rel.split('/').last;
  if (rel == 'main.dart' || rel.startsWith('.injector/')) return 'composition';
  if (name.startsWith('~')) return 'barrel';
  if (name.startsWith('@')) return 'service';
  if (name.startsWith('&')) return 'shared';
  return null;
}

String packageName(String uri) => uri.substring(8).split('/').first;

List<Violation> directViolations(
  String rel,
  List<String> internal,
  List<String> external,
) {
  final found = <Violation>[];
  final layer = layerOf(rel);
  for (final target in internal) {
    if (layer == 'domain' && !target.startsWith('domain/')) {
      found.add(Violation(ViolationKind.domainOutward, target));
    } else if (layer == 'presentation' &&
        (target.startsWith('data/') ||
            target.startsWith('.injector/') ||
            target == 'main.dart' ||
            target.startsWith('domain/repository/'))) {
      found.add(Violation(ViolationKind.presentationBypass, target));
    } else if (layer == 'data' &&
        (target.startsWith('presentation/') ||
            target.startsWith('.injector/') ||
            target == 'main.dart')) {
      found.add(Violation(ViolationKind.dataUpward, target));
    }
  }
  for (final target in external) {
    if (layer == 'domain') {
      if (target.startsWith('package:') &&
          !allowedDomainPackages.contains(packageName(target))) {
        found.add(Violation(ViolationKind.domainSdk, target));
      } else if (forbiddenDomainDartLibs.contains(target)) {
        found.add(Violation(ViolationKind.domainSdk, target));
      }
    } else if (layer == 'presentation' &&
        target.startsWith('package:') &&
        infrastructurePackages.contains(packageName(target))) {
      found.add(Violation(ViolationKind.presentationSdk, target));
    }
  }
  return found;
}

String toNoteId(String rel) =>
    (rel.startsWith('.') ? rel.substring(1) : rel).replaceAll('/', '---');
