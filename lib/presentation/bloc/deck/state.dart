part of 'bloc.dart';

class DeckState extends Equatable {
  final List<DeckEntity> decks;
  final bool isLoading;
  final String errorMessage;

  const DeckState({
    this.decks = const [],
    this.isLoading = false,
    this.errorMessage = '',
  });

  DeckState copyWith({
    List<DeckEntity>? decks,
    bool? isLoading,
    String? errorMessage,
  }) {
    return DeckState(
      decks: decks ?? this.decks,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [decks, isLoading, errorMessage];
}
