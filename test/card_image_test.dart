import 'package:flutter_test/flutter_test.dart';
import 'package:nfc_deck_tracker/domain/entity/card.dart';
import 'package:nfc_deck_tracker/domain/repository/image.dart';
import 'package:nfc_deck_tracker/domain/repository/local_data.dart';
import 'package:nfc_deck_tracker/domain/usecase/clear_user_data.dart';
import 'package:nfc_deck_tracker/domain/usecase/create_card.dart';
import 'package:nfc_deck_tracker/domain/usecase/update_card.dart';

import 'support/test_app.dart';

class RecordingImages implements ImageRepository {
  final calls = <String>[];
  List<String> deleted = [];
  @override
  Future<bool> delete({required List<String> imageUrls}) async {
    calls.add('delete');
    deleted = imageUrls;
    return true;
  }

  @override
  Future<String?> update(
      {required String oldImageUrl, required String newImagePath}) async {
    calls.add('update');
    return newImagePath;
  }

  @override
  Future<String?> upload({required String imagePath}) async {
    calls.add('upload');
    return imagePath;
  }
}

class CountingLocalData implements LocalDataRepository {
  int clears = 0;
  @override
  Future<void> clear() async => clears++;
}

void main() {
  const imageless = CardEntity(cardId: 'a', collectionId: 'x', name: 'A');

  test('guest clearing skips cards without an image and still wipes data',
      () async {
    final cards = MemoryCards()
      ..local['a'] = imageless
      ..local['b'] = imageless.copyWith(cardId: 'b', imageUrl: '/img/b.png');
    final images = RecordingImages();
    final localData = CountingLocalData();

    await ClearUserDataUsecase(
      localDataRepository: localData,
      imageRepository: images,
      cardRepository: cards,
    )(isGuest: true);

    expect(images.deleted, ['/img/b.png']);
    expect(localData.clears, 1);
  });

  test('clearing a signed-in user never deletes images', () async {
    final cards = MemoryCards()
      ..local['b'] = imageless.copyWith(imageUrl: '/img/b.png');
    final images = RecordingImages();

    await ClearUserDataUsecase(
      localDataRepository: CountingLocalData(),
      imageRepository: images,
      cardRepository: cards,
    )(isGuest: false);

    expect(images.calls, isEmpty);
  });

  test('a card without an image is created and updated without image calls',
      () async {
    final cards = MemoryCards();
    final images = RecordingImages();

    final saved = await CreateCardUsecase(
      cardRepository: cards,
      collectionRepository: MemoryCollections(),
      imageRepository: images,
    )(userId: '', card: imageless);
    await UpdateCardUsecase(cardRepository: cards, imageRepository: images)(
        userId: '', card: saved.copyWith(name: 'B'), oldImageUrl: '');

    expect(images.calls, isEmpty);
    expect(cards.local['a']!.name, 'B');
    expect(cards.local['a']!.imageUrl, isNull);
  });
}
