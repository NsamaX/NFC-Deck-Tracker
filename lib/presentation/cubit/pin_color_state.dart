part of 'pin_color_cubit.dart';

class PinColorState extends Equatable {
  final Map<String, Color> pinColor;

  const PinColorState({
    this.pinColor = const {},
  });

  PinColorState copyWith({
    Map<String, Color>? pinColor,
  }) {
    return PinColorState(
      pinColor: pinColor ?? this.pinColor,
    );
  }

  @override
  List<Object> get props => [pinColor];
}
