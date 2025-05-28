import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'pin_color_state.dart';

class PinColorCubit extends Cubit<PinColorState> {
  PinColorCubit() : super(const PinColorState());

  void safeEmit(PinColorState newState) {
    if (!isClosed) emit(newState);
  }

  void togglePinColor({
    required String cardId,
    required Color color,
  }) {
    final updatedColors = Map<String, Color>.from(state.pinColor);

    if (updatedColors[cardId] == color) {
      updatedColors.remove(cardId);
    } else {
      updatedColors[cardId] = color;
    }

    safeEmit(state.copyWith(pinColor: updatedColors));
  }

  void removeColor({
    required String cardId,
  }) {
    final updatedColors = Map<String, Color>.from(state.pinColor);
    updatedColors.remove(cardId);
    safeEmit(state.copyWith(pinColor: updatedColors));
  }

  void resetColor() {
    safeEmit(state.copyWith(pinColor: {}));
  }
}
