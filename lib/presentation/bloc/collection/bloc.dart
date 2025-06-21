import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import 'package:nfc_deck_tracker/domain/entity/card.dart';
import 'package:nfc_deck_tracker/domain/entity/collection.dart';
import 'package:nfc_deck_tracker/domain/usecase/create_collection.dart';
import 'package:nfc_deck_tracker/domain/usecase/delete_collection.dart';
import 'package:nfc_deck_tracker/domain/usecase/fetch_collection.dart';
import 'package:nfc_deck_tracker/domain/usecase/fetch_used_card_distinct.dart';

part 'event.dart';
part 'state.dart';

class CollectionBloc extends Bloc<CollectionEvent, CollectionState> {
  final CreateCollectionUsecase createCollectionUsecase;
  final DeleteCollectionUsecase deleteCollectionUsecase;
  final FetchCollectionUsecase fetchCollectionUsecase;
  final FetchUsedCardDistinctUsecase fetchUsedCardDistinctUsecase;

  CollectionBloc({
    required this.createCollectionUsecase,
    required this.deleteCollectionUsecase,
    required this.fetchCollectionUsecase,
    required this.fetchUsedCardDistinctUsecase,
  }) : super(const CollectionState()) {
    on<CreateCollectionEvent>(_onCreateCollection);
    on<DeleteCollectionEvent>(_onDeleteCollection);
    on<FetchCollectionEvent>(_onFetchCollection);
  }

  Future<void> _onCreateCollection(CreateCollectionEvent event, Emitter<CollectionState> emit) async {
    await createCollectionUsecase(userId: event.userId, name: event.name);
    final collections = await fetchCollectionUsecase(userId: event.userId);
    emit(state.copyWith(collections: collections));
  }

  Future<void> _onDeleteCollection(DeleteCollectionEvent event, Emitter<CollectionState> emit) async {
    await deleteCollectionUsecase(userId: event.userId, collectionId: event.collectionId);
    emit(state.copyWith(
      collections: state.collections.where((c) => c.collectionId != event.collectionId).toList(),
    ));
  }

  Future<void> _onFetchCollection(FetchCollectionEvent event, Emitter<CollectionState> emit) async {
    final collections = await fetchCollectionUsecase(userId: event.userId);
    emit(state.copyWith(collections: collections));
  }

  Future<List<CardEntity>> fetchUsedCardDistinct() async {
    return await fetchUsedCardDistinctUsecase();
  }
}
