import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:nfc_deck_tracker/domain/entity/card.dart';
import 'package:nfc_deck_tracker/domain/usecase/create_card.dart';
import 'package:nfc_deck_tracker/domain/usecase/update_card.dart';
import 'package:nfc_deck_tracker/domain/usecase/delete_card.dart';

part 'card_state.dart';

class CardCubit extends Cubit<CardState> {
  final CreateCardUsecase createCardUsecase;
  final DeleteCardUsecase deleteCardUsecase;
  final UpdateCardUsecase updateCardUsecase;

  CardCubit({
    required this.createCardUsecase,
    required this.deleteCardUsecase,
    required this.updateCardUsecase,
  }) : super(const CardState());

  void safeEmit(CardState newState) {
    if (!isClosed) emit(newState);
  }

  Future<void> createCard({
    required String userId,
    required String collectionId,
  }) async {
    safeEmit(state.copyWith(card: state.card.copyWith(collectionId: collectionId)));
    await createCardUsecase(
      userId: userId,
      card: state.card,
    );
  }

  Future<void> deleteCard({
    required String userId,
    required CardEntity card,
  }) async {
    await deleteCardUsecase(userId: userId, card: card);
  }

  Future<void> updateCard({
    required String userId,
  }) async {
    await updateCardUsecase(userId: userId, card: state.card);
  }

  void setCardName({
    required String name,
  }) {
    safeEmit(state.copyWith(card: state.card.copyWith(name: name)));
  }

  void setCardImageUrl({
    required String imageUrl,
  }) {
    safeEmit(state.copyWith(card: state.card.copyWith(imageUrl: imageUrl)));
  }

  void setCardDescription({
    required String description,
  }) {
    safeEmit(state.copyWith(card: state.card.copyWith(description: description)));
  }

  void setCardAdditionalData({
    required Map<String, dynamic> additionalData,
  }) {
    safeEmit(state.copyWith(card: state.card.copyWith(additionalData: additionalData)));
  }
}
