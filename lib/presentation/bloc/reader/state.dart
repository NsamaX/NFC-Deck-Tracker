part of 'bloc.dart';

class ReaderState extends Equatable {
  final List<CardEntity> readedCards;
  final bool isLoading;
  final String successMessage;
  final String warningMessage;
  final String errorMessage;

  const ReaderState({
    this.readedCards = const [],
    this.isLoading = false,
    this.successMessage = '',
    this.warningMessage = '',
    this.errorMessage = '',
  });

  ReaderState copyWith({
    List<CardEntity>? readedCards,
    bool? isLoading,
    String? successMessage,
    String? warningMessage,
    String? errorMessage,
  }) {
    return ReaderState(
      readedCards: readedCards ?? this.readedCards,
      isLoading: isLoading ?? this.isLoading,
      successMessage: successMessage ?? this.successMessage,
      warningMessage: warningMessage ?? this.warningMessage,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        readedCards,
        isLoading,
        successMessage,
        warningMessage,
        errorMessage,
      ];
}
