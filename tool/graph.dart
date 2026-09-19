import 'dart:io';

import 'rules.dart';

const outputDir = '.obsidian-graph';
const couplingHigh = 10;
const couplingMedium = 5;

class FileNode {
  final String rel;
  final List<String> internal = [];
  final List<String> external = [];
  final List<Violation> violations = [];
  final List<String> tags = [];
  int inDegree = 0;

  FileNode(this.rel);

  String get id => toNoteId(rel);
  String get layer => layerOf(rel);
  int get coupling => inDegree + internal.length;
}

Future<void> main(List<String> args) async {
  final check = args.contains('--check');
  final nodes = <String, FileNode>{};
  for (final rel in listDartFiles()) {
    final node = FileNode(rel);
    for (final dep in dependencies(File('lib/$rel').readAsStringSync(), rel)) {
      final list = dep.isInternal ? node.internal : node.external;
      if (!list.contains(dep.target)) list.add(dep.target);
    }
    node.internal.sort();
    node.external.sort();
    nodes[rel] = node;
  }

  for (final node in nodes.values) {
    node.violations
        .addAll(directViolations(node.rel, node.internal, node.external));
    for (final target in node.internal) {
      nodes[target]?.inDegree++;
    }
  }
  for (final node in nodes.values) {
    if (inCycle(node.rel, nodes)) node.violations.add(Violation.circular);
  }
  for (final node in nodes.values) {
    node.tags.addAll(tagsFor(node));
  }

  final out = Directory(outputDir);
  if (out.existsSync()) {
    for (final entity in out.listSync()) {
      if (entity is File && entity.path.endsWith('.md')) entity.deleteSync();
    }
  }
  Directory('$outputDir/.obsidian').createSync(recursive: true);
  writeObsidianConfig();
  for (final node in nodes.values) {
    File('$outputDir/${node.id}.md').writeAsStringSync(noteFor(node));
  }
  writeViolationReport(nodes);
  writeGraphContext(nodes);

  final violated = nodes.values.where((n) => n.violations.isNotEmpty).length;
  stdout.writeln('Generated ${nodes.length} notes into $outputDir/');
  stdout.writeln('Files with violations: $violated');
  if (check && violated > 0) exit(1);
}

Iterable<String> listDartFiles() sync* {
  final root = Directory('lib').absolute.uri.toString();
  final files = Directory('lib')
      .listSync(recursive: true)
      .whereType<File>()
      .where((f) => f.path.endsWith('.dart'))
      .toList()
    ..sort((a, b) => a.path.compareTo(b.path));
  for (final file in files) {
    yield file.absolute.uri.toString().substring(root.length);
  }
}

bool inCycle(String start, Map<String, FileNode> nodes) {
  final visited = <String>{start};
  bool dfs(String current) {
    for (final next in nodes[current]?.internal ?? const <String>[]) {
      if (next == start) return true;
      if (!visited.add(next)) continue;
      if (dfs(next)) return true;
    }
    return false;
  }

  return dfs(start);
}

List<String> tagsFor(FileNode node) {
  final tags = <String>['layer/${node.layer}'];
  final role = roleOf(node.rel);
  if (role != null) tags.add('role/$role');
  final entry = entryOf(node.rel);
  if (entry != null) tags.add('entry/$entry');
  for (final v in node.violations) {
    final tag = 'violation/${v.slug}';
    if (!tags.contains(tag)) tags.add(tag);
  }
  if (node.coupling >= couplingHigh) {
    tags.add('coupling/high');
  } else if (node.coupling >= couplingMedium) {
    tags.add('coupling/medium');
  }
  return tags;
}

String noteFor(FileNode node) {
  final b = StringBuffer()
    ..writeln('---')
    ..writeln('tags:');
  for (final tag in node.tags) {
    b.writeln('  - $tag');
  }
  b
    ..writeln('---')
    ..writeln()
    ..writeln('# ${node.rel.split('/').last}')
    ..writeln()
    ..writeln('`lib/${node.rel}`')
    ..writeln();
  if (node.internal.isNotEmpty) {
    b.writeln('## Imports');
    for (final t in node.internal) {
      b.writeln('- [[${toNoteId(t)}]]');
    }
    b.writeln();
  }
  if (node.external.isNotEmpty) {
    b.writeln('## Packages');
    for (final t in node.external) {
      b.writeln('- `$t`');
    }
    b.writeln();
  }
  if (node.violations.isNotEmpty) {
    b.writeln('## Violations');
    for (final v in node.violations) {
      b.writeln('- ${v.label}${v.detail.isEmpty ? '' : ': `${v.detail}`'}');
    }
    b.writeln();
  }
  return b.toString();
}

void writeViolationReport(Map<String, FileNode> nodes) {
  final byKind = {
    for (final kind in ViolationKind.values) kind: <(FileNode, Violation)>[],
  };
  for (final node in nodes.values) {
    for (final v in node.violations) {
      byKind[v.kind]!.add((node, v));
    }
  }
  final violated = nodes.values.where((n) => n.violations.isNotEmpty).length;
  final b = StringBuffer()
    ..writeln('# Architecture Violation Report')
    ..writeln()
    ..writeln('> Generated: ${DateTime.now().toIso8601String()}')
    ..writeln('> Files with violations: **$violated**')
    ..writeln()
    ..writeln('| Severity | Violation | Count |')
    ..writeln('|---|---|---|');
  for (final kind in ViolationKind.values) {
    b.writeln('| ${kind.severity} | ${kind.label} | ${byKind[kind]!.length} |');
  }
  b.writeln();
  for (final kind in ViolationKind.values) {
    final items = byKind[kind]!;
    if (items.isEmpty) continue;
    b
      ..writeln('## ${kind.label} (${items.length})')
      ..writeln()
      ..writeln(kind.description)
      ..writeln();
    for (final (node, v) in items) {
      b.writeln(
          '- `lib/${node.rel}`${v.detail.isEmpty ? '' : ' -> `${v.detail}`'}');
    }
    b.writeln();
  }
  if (violated == 0) {
    b.writeln('No violations found. Layer boundaries are clean.');
  }
  File('$outputDir/.VIOLATIONS.md').writeAsStringSync(b.toString());
}

void writeGraphContext(Map<String, FileNode> nodes) {
  final layers = <String, List<FileNode>>{};
  final layerDeps = <String, Map<String, int>>{};
  final packages = <String, int>{};
  for (final node in nodes.values) {
    layers.putIfAbsent(node.layer, () => []).add(node);
    for (final t in node.internal) {
      final to = layerOf(t);
      if (to == node.layer) continue;
      layerDeps
          .putIfAbsent(node.layer, () => {})
          .update(to, (n) => n + 1, ifAbsent: () => 1);
    }
    for (final p in node.external) {
      packages.update(p, (n) => n + 1, ifAbsent: () => 1);
    }
  }
  final edges = nodes.values.fold<int>(0, (s, n) => s + n.internal.length);
  final orphans =
      nodes.values.where((n) => n.internal.isEmpty && n.inDegree == 0);
  final coupled = nodes.values.toList()
    ..sort((a, b) => b.coupling.compareTo(a.coupling));
  final violated = nodes.values.where((n) => n.violations.isNotEmpty).length;

  final b = StringBuffer()
    ..writeln('# Graph Context')
    ..writeln('> Generated: ${DateTime.now().toIso8601String()}')
    ..writeln(
        '> Attach this file when asking an external AI about the dependency graph.')
    ..writeln()
    ..writeln('## Overview')
    ..writeln('- Files: ${nodes.length}')
    ..writeln('- Internal edges: $edges')
    ..writeln('- Files with violations: $violated (see .VIOLATIONS.md)')
    ..writeln('- Orphans: ${orphans.length}')
    ..writeln()
    ..writeln('## Rules')
    ..writeln(
        '- domain imports only domain, `dart:` core libraries, ${allowedDomainPackages.join(', ')}')
    ..writeln(
        '- presentation imports domain entities, use cases, and values; never data, .injector, main, domain/repository, or infrastructure SDKs')
    ..writeln(
        '- data implements domain ports; never imports presentation, .injector, or main')
    ..writeln('- no import cycles')
    ..writeln()
    ..writeln('## Node Color Legend')
    ..writeln('| Color | Meaning |')
    ..writeln('|---|---|')
    ..writeln('| Red | Circular dependency |')
    ..writeln('| Orange-red | Domain depends outward or on a framework |')
    ..writeln('| Orange | Presentation bypasses use cases or uses an SDK |')
    ..writeln('| Yellow | Data depends on presentation or composition |')
    ..writeln('| Pink | Composition (main.dart, .injector) |')
    ..writeln('| Purple | Domain port (repository interface) |')
    ..writeln('| Violet | Use case |')
    ..writeln('| Blue | Page |')
    ..writeln('| Light blue | Bloc |')
    ..writeln('| Cyan | Data source service (`*_service.dart`) |')
    ..writeln('| Green | Repository implementation |')
    ..writeln()
    ..writeln('## Layers')
    ..writeln('| Layer | Files | Internal edges out |')
    ..writeln('|---|---|---|');
  for (final entry in layers.entries.toList()
    ..sort((a, b) => a.key.compareTo(b.key))) {
    final out = entry.value.fold<int>(0, (s, n) => s + n.internal.length);
    b.writeln('| ${entry.key} | ${entry.value.length} | $out |');
  }
  b
    ..writeln()
    ..writeln('## Layer dependencies (file-level edge counts)')
    ..writeln('| From | To | Edges |')
    ..writeln('|---|---|---|');
  for (final from in layerDeps.keys.toList()..sort()) {
    for (final to in layerDeps[from]!.keys.toList()..sort()) {
      b.writeln('| $from | $to | ${layerDeps[from]![to]} |');
    }
  }
  b
    ..writeln()
    ..writeln('## Package usage (files importing each package)')
    ..writeln('| Package | Files |')
    ..writeln('|---|---|');
  for (final p in packages.keys.toList()
    ..sort((a, b) => packages[b]!.compareTo(packages[a]!))) {
    b.writeln('| `$p` | ${packages[p]} |');
  }
  b
    ..writeln()
    ..writeln('## Most coupled files (in + out degree)')
    ..writeln('| File | In | Out | Score |')
    ..writeln('|---|---|---|---|');
  for (final n in coupled.take(15)) {
    b.writeln(
        '| `lib/${n.rel}` | ${n.inDegree} | ${n.internal.length} | ${n.coupling} |');
  }
  if (orphans.isNotEmpty) {
    b
      ..writeln()
      ..writeln('## Orphans (no internal edges in either direction)');
    for (final n in orphans) {
      b.writeln('- `lib/${n.rel}`');
    }
  }
  File('$outputDir/.GRAPH-CONTEXT.md').writeAsStringSync(b.toString());
}

void writeObsidianConfig() {
  const groups = [
    ('tag:#violation/circular-dep', 0xEF4444),
    ('tag:#violation/domain-outward', 0xF97316),
    ('tag:#violation/domain-sdk', 0xF97316),
    ('tag:#violation/presentation-bypass', 0xFB923C),
    ('tag:#violation/presentation-sdk', 0xFB923C),
    ('tag:#violation/data-upward', 0xFDE047),
    ('tag:#entry/composition', 0xF628D7),
    ('tag:#role/port', 0x8B5CF6),
    ('tag:#role/usecase', 0xA855F7),
    ('tag:#role/page', 0x3B82F6),
    ('tag:#role/bloc', 0x60A5FA),
    ('tag:#entry/service', 0x06B6D4),
    ('tag:#role/repository', 0x14B8A6),
  ];
  final colorGroups = groups
      .map((g) => '{"query":"${g.$1}","color":{"a":1,"rgb":${g.$2}}}')
      .join(',');
  File('$outputDir/.obsidian/graph.json').writeAsStringSync(
    '{"collapse-filter":false,"search":"","showTags":false,'
    '"showAttachments":false,"hideUnresolved":false,"showOrphans":true,'
    '"collapse-color-groups":false,"colorGroups":[$colorGroups],'
    '"collapse-display":true,"showArrow":true,"textFadeMultiplier":0,'
    '"nodeSizeMultiplier":1.2,"lineSizeMultiplier":1,"collapse-forces":true,'
    '"centerStrength":0.5,"repelStrength":10,"linkStrength":1,'
    '"linkDistance":250,"scale":0.5,"close":false}',
  );
  File('$outputDir/.obsidian/app.json').writeAsStringSync('{}');
  File('$outputDir/.obsidian/core-plugins.json')
      .writeAsStringSync('["graph","search","file-explorer","tag-pane"]');
}
