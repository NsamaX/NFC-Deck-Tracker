part of 'reader_cubit.dart';

class ReaderState extends Equatable {
  final bool isLoading;
  final String successMessage;
  final String warningMessage;
  final String errorMessage;

  final List<CardEntity> scannedCards;

  const ReaderState({
    this.isLoading = false,
    this.successMessage = '',
    this.warningMessage = '',
    this.errorMessage = '',
    this.scannedCards = const [],
  });

  ReaderState copyWith({
    bool? isLoading,
    String? successMessage,
    String? warningMessage,
    String? errorMessage,
    List<CardEntity>? scannedCards,
  }) {
    return ReaderState(
      isLoading: isLoading ?? this.isLoading,
      successMessage: successMessage ?? this.successMessage,
      warningMessage: warningMessage ?? this.warningMessage,
      errorMessage: errorMessage ?? this.errorMessage,
      scannedCards: scannedCards ?? this.scannedCards,
    );
  }

  @override
  List<Object?> get props => [
        isLoading,
        successMessage,
        warningMessage,
        errorMessage,
        scannedCards,
      ];
}
