import 'dart:io';

const registryPath = '.claude/registry.md';

class Section {
  final String title;
  String? source;
  bool checkMembers = false;
  final List<Entry> entries = [];

  Section(this.title);
}

class Entry {
  final String name;
  final String file;
  final List<String> members = [];

  Entry(this.name, this.file);
}

final _section = RegExp(r'^## (.+)$');
final _source = RegExp(r'^Source: `([^`]+)`');
final _check = RegExp(r'^Check: (.+)$');
final _entry = RegExp(r'^### (\w+) \(`([^`]+)`\)');
final _member = RegExp(r'^- `(\w+)(?:\(.*)?`');

void main() {
  final file = File(registryPath);
  if (!file.existsSync()) {
    stderr.writeln('Registry not found: $registryPath');
    exit(1);
  }
  final sections = parse(file.readAsLinesSync());
  final problems = <String>[];
  var entries = 0;

  for (final section in sections) {
    if (section.source == null) continue;
    final dir = Directory(section.source!);
    if (!dir.existsSync()) {
      problems.add('${section.title}: source directory missing (${section.source})');
      continue;
    }
    final declaredFiles = section.entries.map((e) => e.file).toSet();
    final onDisk = dir
        .listSync()
        .whereType<File>()
        .map((f) => f.uri.pathSegments.last)
        .where((n) => n.endsWith('.dart') && !n.startsWith('~'))
        .toSet();
    for (final name in onDisk.difference(declaredFiles).toList()..sort()) {
      problems.add('${section.title}: `$name` exists on disk but is not in the registry');
    }
    for (final entry in section.entries) {
      entries++;
      final path = '${section.source}${entry.file}';
      final source = File(path);
      if (!source.existsSync()) {
        problems.add('${section.title}: ${entry.name} points to missing file $path');
        continue;
      }
      final text = source.readAsStringSync();
      final body = classBody(text, entry.name);
      if (body == null) {
        problems.add('${section.title}: `${entry.name}` is not declared in $path');
        continue;
      }
      if (!section.checkMembers) continue;
      final actual = publicMembers(body, entry.name);
      for (final m in actual.difference(entry.members.toSet()).toList()..sort()) {
        problems.add('${section.title}: ${entry.name}.$m exists but is not in the registry');
      }
      for (final m in entry.members.toSet().difference(actual).toList()..sort()) {
        problems.add('${section.title}: ${entry.name}.$m is in the registry but not in code');
      }
    }
  }

  stdout.writeln('Registry verification: $registryPath');
  stdout.writeln('Sections: ${sections.where((s) => s.source != null).length}, entries: $entries');
  if (problems.isEmpty) {
    stdout.writeln('OK');
    return;
  }
  for (final p in problems) {
    stdout.writeln('- $p');
  }
  stdout.writeln('FAIL: ${problems.length} problem(s)');
  exit(1);
}

List<Section> parse(List<String> lines) {
  final sections = <Section>[];
  for (final line in lines) {
    final s = _section.firstMatch(line);
    if (s != null) {
      sections.add(Section(s.group(1)!));
      continue;
    }
    if (sections.isEmpty) continue;
    final current = sections.last;
    final src = _source.firstMatch(line);
    if (src != null) {
      current.source = src.group(1)!;
      continue;
    }
    final check = _check.firstMatch(line);
    if (check != null) {
      current.checkMembers = check.group(1)!.contains('members');
      continue;
    }
    final e = _entry.firstMatch(line);
    if (e != null) {
      current.entries.add(Entry(e.group(1)!, e.group(2)!));
      continue;
    }
    final m = _member.firstMatch(line);
    if (m != null && current.entries.isNotEmpty) {
      current.entries.last.members.add(m.group(1)!);
    }
  }
  return sections;
}

String? classBody(String text, String name) {
  final decl = RegExp(
    '^(?:abstract |sealed |final |base )*(?:interface )?(?:class|enum|mixin) $name\\b[^{]*\\{',
    multiLine: true,
  ).firstMatch(text);
  if (decl == null) return null;
  var depth = 0;
  for (var i = decl.end - 1; i < text.length; i++) {
    if (text[i] == '{') depth++;
    if (text[i] == '}' && --depth == 0) return text.substring(decl.end, i);
  }
  return null;
}

Set<String> publicMembers(String body, String className) {
  final members = <String>{};
  final method = RegExp(r'^  (?!static |final |const |late |@)[A-Za-z_][\w<>, ?]*\s+([a-z]\w*)\s*\(', multiLine: true);
  final getter = RegExp(r'^  [A-Za-z_][\w<>, ?]*\s+get\s+([a-z]\w*)', multiLine: true);
  for (final m in method.allMatches(body)) {
    members.add(m.group(1)!);
  }
  for (final g in getter.allMatches(body)) {
    members.add(g.group(1)!);
  }
  return members;
}
