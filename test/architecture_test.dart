import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

Iterable<String> dependencies(String source) sync* {
  final directives = RegExp(
    r'''^\s*(?:import|export|part(?:\s+of)?)\s+([^;]+);''',
    multiLine: true,
  );
  for (final directive in directives.allMatches(source)) {
    for (final uri
        in RegExp(r'''['"]([^'"]+)['"]''').allMatches(directive.group(1)!)) {
      yield uri.group(1)!;
    }
  }
}

void main() {
  test('layer dependencies point inward, including shared code and barrels',
      () {
    final root = Directory('lib').absolute.uri;
    final violations = <String>[];
    final files = Directory('lib')
        .listSync(recursive: true)
        .whereType<File>()
        .where((file) => file.path.endsWith('.dart'));
    const domainPackages = {'equatable', 'uuid'};
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
    final edges = <String, List<String>>{};
    for (final file in files) {
      final path = root.relativize(file.absolute.uri);
      edges[path] = dependencies(file.readAsStringSync()).map((dependency) {
        if (dependency.startsWith('package:nfc_deck_tracker/')) {
          return dependency.substring('package:nfc_deck_tracker/'.length);
        }
        if (dependency.contains(':')) return dependency;
        return root.relativize(file.absolute.uri.resolve(dependency));
      }).toList();
    }
    for (final start in edges.keys) {
      if (!start.startsWith('domain/') &&
          !start.startsWith('presentation/') &&
          !start.startsWith('data/')) continue;
      final visited = <String>{};
      void visit(String file) {
        if (!visited.add(file)) return;
        for (final target in edges[file] ?? <String>[]) {
          String? problem;
          if (start.startsWith('domain/')) {
            if (target.startsWith('package:')) {
              final package = target.substring(8).split('/').first;
              if (!domainPackages.contains(package))
                problem = 'framework/package';
            } else if (target.startsWith('dart:')) {
              if (['dart:io', 'dart:ui', 'dart:html'].contains(target))
                problem = 'platform I/O';
            } else if (!target.startsWith('domain/')) {
              problem = 'outward dependency';
            }
          } else if (start.startsWith('presentation/')) {
            if (target.startsWith('data/') ||
                target.startsWith('.injector/') ||
                target == 'main.dart' ||
                target.startsWith('domain/repository/')) {
              problem = 'bypasses use cases';
            }
            if (target.startsWith('package:') &&
                infrastructurePackages
                    .contains(target.substring(8).split('/').first))
              problem = 'infrastructure SDK';

            if (file.startsWith('domain/')) continue;
          } else if (target.startsWith('presentation/') ||
              target.startsWith('.injector/') ||
              target == 'main.dart') {
            problem = 'depends on UI/composition';
          }
          if (problem != null)
            violations.add('$start -> $file -> $target ($problem)');
          if (edges.containsKey(target)) visit(target);
        }
      }

      visit(start);
    }
    expect(violations, isEmpty, reason: violations.join('\n'));
  });
}

extension on Uri {
  String relativize(Uri file) => file.toString().substring(toString().length);
}
