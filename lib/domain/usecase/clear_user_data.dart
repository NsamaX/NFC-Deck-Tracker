import '../repository/local_data.dart';
import '../repository/image.dart';
import '../repository/card.dart';

class ClearUserDataUsecase {
  final LocalDataRepository localDataRepository;
  final ImageRepository imageRepository;
  final CardRepository cardRepository;

  ClearUserDataUsecase({
    required this.localDataRepository,
    required this.imageRepository,
    required this.cardRepository,
  });

  Future<void> call({
    required bool isGuest,
  }) async {
    if (isGuest) {
      final cards = await cardRepository.fetchUsedCards();
      final imageUrls = [
        for (final card in cards)
          if (card.imageUrl case final url? when url.isNotEmpty) url,
      ];
      if (imageUrls.isNotEmpty) {
        await imageRepository.delete(imageUrls: imageUrls);
      }
    }

    await localDataRepository.clear();
  }
}
