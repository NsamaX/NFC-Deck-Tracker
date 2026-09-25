import 'dart:ui';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'event.dart';
part 'state.dart';

class PinCardBloc extends Bloc<PinCardEvent, PinCardState> {
  PinCardBloc() : super(const PinCardState()) {
    on<PinColorEvent>(_onPinColor);
  }

  void _onPinColor(PinColorEvent event, Emitter<PinCardState> emit) {
    final updatedColors = Map<String, Color>.from(state.pinColor);

    if (updatedColors[event.cardId] == event.color) {
      updatedColors.remove(event.cardId);
    } else {
      updatedColors[event.cardId] = event.color;
    }

    emit(state.copyWith(pinColor: updatedColors));
  }
}
