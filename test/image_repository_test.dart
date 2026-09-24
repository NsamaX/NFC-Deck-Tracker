import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:nfc_deck_tracker/data/datasource/remote/supabase_service.dart';
import 'package:nfc_deck_tracker/data/repository/image.dart';

void main() {
  late Directory dir;
  final images =
      ImageRepositoryImpl(supabaseService: SupabaseService.offline());

  setUp(() async => dir = await Directory.systemTemp.createTemp('images'));
  tearDown(() => dir.delete(recursive: true));

  File image(String name) => File('${dir.path}/$name')..writeAsStringSync('x');

  test('replacing a guest image keeps the new file and removes the old one',
      () async {
    final old = image('old.png');
    final replacement = image('new.png');

    final result = await images.update(
        oldImageUrl: old.path, newImagePath: replacement.path);

    expect(result, replacement.path);
    expect(old.existsSync(), isFalse);
    expect(replacement.existsSync(), isTrue);
  });

  test('deleting guest images removes local files and skips remote urls',
      () async {
    final local = image('card.png');

    expect(
        await images.delete(
            imageUrls: [local.path, '', 'https://example.test/card.png']),
        isTrue);
    expect(local.existsSync(), isFalse);
  });

  test('a guest upload keeps the local file it points to', () async {
    final local = image('card.png');
    expect(await images.upload(imagePath: local.path), local.path);
    expect(local.existsSync(), isTrue);
  });
}
