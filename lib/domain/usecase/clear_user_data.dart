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
    final cards = await cardRepository.fetchUsedCards();

    if (isGuest && cards.isNotEmpty) {
      final List<String> imageUrls =
          cards.map((card) => card.imageUrl!).toList();
      await imageRepository.delete(imageUrls: imageUrls);
    }

    await localDataRepository.clear();
  }
}
