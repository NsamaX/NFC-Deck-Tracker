part of 'reader_cubit.dart';

class ReaderState extends Equatable {
  final bool isLoading;
  final String errorMessage;
  final String successMessage;

  final List<CardEntity> scannedCards;

  const ReaderState({
    this.isLoading = false,
    this.errorMessage = '',
    this.successMessage = '',
    this.scannedCards = const [],
  });

  ReaderState copyWith({
    bool? isLoading,
    String? errorMessage,
    String? successMessage,
    List<CardEntity>? scannedCards,
  }) {
    return ReaderState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      successMessage: successMessage ?? this.successMessage,
      scannedCards: scannedCards ?? this.scannedCards,
    );
  }

  @override
  List<Object?> get props => [
        isLoading,
        errorMessage,
        successMessage,
        scannedCards,
      ];
}
