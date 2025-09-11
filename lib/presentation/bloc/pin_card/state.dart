part of 'bloc.dart';

class PinCardState extends Equatable {
  final Map<String, Color> pinColor;

  const PinCardState({
    this.pinColor = const {},
  });

  PinCardState copyWith({
    Map<String, Color>? pinColor,
  }) {
    return PinCardState(
      pinColor: pinColor ?? this.pinColor,
    );
  }

  @override
  List<Object> get props => [pinColor];
}
