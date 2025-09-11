import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:nfc_deck_tracker/domain/entity/card.dart';
import 'package:nfc_deck_tracker/domain/usecase/create_card.dart';
import 'package:nfc_deck_tracker/domain/usecase/update_card.dart';

import '../../locale/localization.dart';

part 'event.dart';
part 'state.dart';

class CardBloc extends Bloc<CardEvent, CardState> {
  final CreateCardUsecase createCardUsecase;
  final UpdateCardUsecase updateCardUsecase;

  CardBloc({
    required this.createCardUsecase,
    required this.updateCardUsecase,
  }) : super(const CardState()) {
    on<SetCardNameEvent>(_onSetCardName);
    on<SetCardImageUrlEvent>(_onSetCardImageUrl);
    on<SetCardDescriptionEvent>(_onSetCardDescription);
    on<SetCardAdditionalDataEvent>(_onSetCardAdditionalData);
    on<CreateCardEvent>(_onCreateCard);
    on<UpdateCardEvent>(_onUpdateCard);
  }

  void _onSetCardName(SetCardNameEvent event, Emitter<CardState> emit) {
    emit(state.copyWith(card: state.card.copyWith(name: event.name)));
  }

  void _onSetCardImageUrl(SetCardImageUrlEvent event, Emitter<CardState> emit) {
    emit(state.copyWith(card: state.card.copyWith(imageUrl: event.imageUrl)));
  }

  void _onSetCardDescription(SetCardDescriptionEvent event, Emitter<CardState> emit) {
    emit(state.copyWith(card: state.card.copyWith(description: event.description)));
  }

  void _onSetCardAdditionalData(SetCardAdditionalDataEvent event, Emitter<CardState> emit) {
    emit(state.copyWith(card: state.card.copyWith(additionalData: event.additionalData)));
  }

  Future<void> _onCreateCard(CreateCardEvent event, Emitter<CardState> emit) async {
    final updatedCard = state.card.copyWith(
      collectionId: event.collectionId,
      description: event.locale.translate('card.no_description'),
    );
    await createCardUsecase(userId: event.userId, card: updatedCard);
    emit(state.copyWith(card: updatedCard));
  }

  Future<void> _onUpdateCard(UpdateCardEvent event, Emitter<CardState> emit) async {
    await updateCardUsecase(userId: event.userId, card: state.card, oldImageUrl: state.oldImageUrl);
  }
}
