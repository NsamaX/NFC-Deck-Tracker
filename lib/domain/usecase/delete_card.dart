import '../repository/pending_delete.dart';
import '../service/sync_policy.dart';
import '../value/sync_kind.dart';
import '../repository/card.dart';
import '../repository/image.dart';

class DeleteCardUsecase {
  final CardRepository cardRepository;
  final PendingDeleteRepository pendingDeletes;
  final ImageRepository imageRepository;

  DeleteCardUsecase({
    required this.cardRepository,
    required this.pendingDeletes,
    required this.imageRepository,
  });

  Future<void> call({
    required String userId,
    required String collectionId,
    required String cardId,
    required String imageUrl,
  }) async {
    await const SyncPolicy().delete(
      userId: userId,
      local: () => cardRepository.deleteForLocal(
          collectionId: collectionId, cardId: cardId),
      remote: () => cardRepository.deleteForRemote(
          userId: userId, collectionId: collectionId, cardId: cardId),
      rememberPending: () =>
          pendingDeletes.add(userId: userId, kind: SyncKind.card, id: cardId),
    );

    await imageRepository.delete(imageUrls: [imageUrl]);
  }
}
