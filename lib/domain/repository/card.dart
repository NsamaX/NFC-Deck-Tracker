import '../entity/card.dart';

abstract interface class CardRepository {
  Future<int> check({
    required String collectionId,
    required String name,
  });

  Future<void> createForLocal({
    required CardEntity card,
  });

  Future<bool> createForRemote({
    required String userId,
    required CardEntity card,
  });

  Future<void> deleteForLocal({
    required String collectionId,
    required String cardId,
  });

  Future<bool> deleteForRemote({
    required String userId,
    required String collectionId,
    required String cardId,
  });

  Future<List<CardEntity>> fetchForLocal({
    required String collectionId,
  });

  Future<List<CardEntity>> fetchForRemote({
    required String userId,
    required String collectionId,
  });

  Future<List<CardEntity>> fetchUsedCards();

  Future<CardEntity?> findForApi({
    required String collectionId,
    required String cardId,
  });

  Future<CardEntity?> findForLocal({
    required String collectionId,
    required String cardId,
  });

  Future<void> save({
    required List<CardEntity> cards,
  });

  Future<void> updateForLocal({
    required CardEntity card,
  });

  Future<bool> updateForRemote({
    required String userId,
    required CardEntity card,
  });
}
