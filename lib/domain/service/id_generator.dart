import 'package:uuid/uuid.dart';

class IdGenerator {
  const IdGenerator();

  String next() => const Uuid().v4();
}
