import 'dart:io';

const steps = [
  ('graph', ['run', 'tool/graph.dart', '--check']),
  ('registry', ['run', 'tool/verify_registry.dart']),
  ('analyze', ['analyze']),
];

Future<void> main() async {
  var failed = 0;
  for (final (name, args) in steps) {
    stdout.writeln('== $name');
    final result = await Process.run('dart', args, runInShell: true);
    stdout.write(result.stdout);
    stderr.write(result.stderr);
    if (result.exitCode != 0) failed++;
  }
  stdout.writeln(failed == 0 ? 'verify: OK' : 'verify: $failed step(s) failed');
  exit(failed == 0 ? 0 : 1);
}
