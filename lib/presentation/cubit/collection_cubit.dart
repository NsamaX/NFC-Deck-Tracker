import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:nfc_deck_tracker/domain/entity/card.dart';
import 'package:nfc_deck_tracker/domain/entity/collection.dart';
import 'package:nfc_deck_tracker/domain/usecase/create_collection.dart';
import 'package:nfc_deck_tracker/domain/usecase/delete_collection.dart';
import 'package:nfc_deck_tracker/domain/usecase/fetch_collection.dart';
import 'package:nfc_deck_tracker/domain/usecase/fetch_used_card_distinct.dart';

part 'collection_state.dart';

class CollectionCubit extends Cubit<CollectionState> {
  final CreateCollectionUsecase createCollectionUsecase;
  final DeleteCollectionUsecase deleteCollectionUsecase;
  final FetchCollectionUsecase fetchCollectionUsecase;
  final FetchUsedCardDistinctUsecase fetchUsedCardDistinctUsecase;

  CollectionCubit({
    required this.createCollectionUsecase,
    required this.deleteCollectionUsecase,
    required this.fetchCollectionUsecase,
    required this.fetchUsedCardDistinctUsecase,
  }) : super(const CollectionState());

  void safeEmit(CollectionState newState) {
    if (!isClosed) emit(newState);
  }

  Future<void> createCollection({
    required String userId,
    required String name,
  }) async {
    await createCollectionUsecase(userId: userId, name: name);
    fetchCollection(userId: userId);
  }

  Future<void> deleteCollection({
    required String userId,
    required String collectionId,
  }) async {
    await deleteCollectionUsecase(userId: userId, collectionId: collectionId);
    safeEmit(state.copyWith(collections: state.collections.where((c) => c.collectionId != collectionId).toList()));
  }

  Future<void> fetchCollection({
    required String userId,
  }) async {
    final List<CollectionEntity> collections = await fetchCollectionUsecase(userId: userId);
    safeEmit(state.copyWith(collections: collections));
  }

  Future<List<CardEntity>> fetchUsedCardDistinct() async {
    final List<CardEntity> allUsedCardDistinct = await fetchUsedCardDistinctUsecase.call();
    return allUsedCardDistinct;
  }
}
