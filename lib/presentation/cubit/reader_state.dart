part of 'reader_cubit.dart';

class ReaderState extends Equatable {
  final bool isLoading;
  final String errorMessage;

  final List<CardEntity> scannedCards;

  const ReaderState({
    this.isLoading = false,
    this.errorMessage = '',
    this.scannedCards = const [],
  });

  ReaderState copyWith({
    bool? isLoading,
    String? errorMessage,
    List<CardEntity>? scannedCards,
  }) {
    return ReaderState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      scannedCards: scannedCards ?? this.scannedCards,
    );
  }

  @override
  List<Object?> get props => [
        isLoading,
        errorMessage,
        scannedCards,
      ];
}
