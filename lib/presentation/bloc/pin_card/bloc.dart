import 'dart:ui';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'event.dart';
part 'state.dart';

class PinCardBloc extends Bloc<PinCardEvent, PinCardState> {
  PinCardBloc() : super(const PinCardState()) {
    on<PinColorEvent>(_onTogglePinColor);
    on<RemoveColorEvent>(_onRemoveColor);
    on<ResetColorEvent>(_onResetColor);
  }

  void _onTogglePinColor(PinColorEvent event, Emitter<PinCardState> emit) {
    final updatedColors = Map<String, Color>.from(state.pinColor);

    if (updatedColors[event.cardId] == event.color) {
      updatedColors.remove(event.cardId);
    } else {
      updatedColors[event.cardId] = event.color;
    }

    emit(state.copyWith(pinColor: updatedColors));
  }

  void _onRemoveColor(RemoveColorEvent event, Emitter<PinCardState> emit) {
    final updatedColors = Map<String, Color>.from(state.pinColor);
    updatedColors.remove(event.cardId);
    emit(state.copyWith(pinColor: updatedColors));
  }

  void _onResetColor(ResetColorEvent event, Emitter<PinCardState> emit) {
    emit(state.copyWith(pinColor: {}));
  }
}
