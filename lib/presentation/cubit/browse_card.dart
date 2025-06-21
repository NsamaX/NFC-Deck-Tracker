// import 'package:equatable/equatable.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';

// import 'package:nfc_deck_tracker/domain/entity/card.dart';
// import 'package:nfc_deck_tracker/domain/usecase/fetch_card.dart';

// class BrowseCardCubit extends Cubit<BrowseCardState> {
//   final FetchCardUsecase fetchCardUsecase;

//   BrowseCardCubit({
//     required this.fetchCardUsecase,
//   }) : super(const BrowseCardState());

//   Future<void> fetchCard({
//     required String userId,
//     required String collectionId,
//     required String collectionName,
//   }) async {
//     if (state.isLoading || isClosed) return;

//     if (!isClosed) {
//       emit(state.copyWith(
//         isLoading: true,
//         errorMessage: '',
//       ));
//     }

//     try {
//       final loadedCards = await fetchCardUsecase(
//         userId: userId,
//         collectionId: collectionId,
//         collectionName: collectionName,
//       );

//       if (!isClosed) {
//         emit(state.copyWith(
//           cards: loadedCards,
//           visibleCards: loadedCards,
//           isLoading: false,
//         ));
//       }

//       if (loadedCards.isEmpty && !isClosed) {
//         emit(state.copyWith(
//           errorMessage: 'page_browse_card.empty_collection',
//         ));
//       }
//     } catch (_) {
//       if (!isClosed) {
//         emit(state.copyWith(
//           errorMessage: 'page_browse_card.error_fetch_card',
//           isLoading: false,
//         ));
//       }
//     }
//   }

//   void filterCardByName({
//     required String query,
//   }) {
//     if (isClosed) return;

//     final keyword = query.trim();

//     if (keyword.isEmpty) {
//       resetSearch();
//       return;
//     }

//     final results = state.cards
//         .where((card) => (card.name ?? '')
//             .toLowerCase()
//             .contains(keyword.toLowerCase()))
//         .toList();

//     emit(state.copyWith(
//       visibleCards: results,
//       errorMessage: results.isEmpty
//           ? 'page_browse_card.empty_search_result'
//           : '',
//     ));
//   }

//   void resetSearch() {
//     emit(state.copyWith(
//       visibleCards: state.cards,
//       errorMessage: '',
//     ));
//   }
// }

// class BrowseCardState extends Equatable {
//   final bool isLoading;
//   final String errorMessage;

//   final List<CardEntity> cards;
//   final List<CardEntity> visibleCards;

//   const BrowseCardState({
//     this.isLoading = false,
//     this.errorMessage = '',
//     this.cards = const [],
//     this.visibleCards = const [],
//   });

//   BrowseCardState copyWith({
//     bool? isLoading,
//     String? errorMessage,
//     List<CardEntity>? cards,
//     List<CardEntity>? visibleCards,
//   }) {
//     return BrowseCardState(
//       isLoading: isLoading ?? this.isLoading,
//       errorMessage: errorMessage ?? this.errorMessage,
//       cards: cards ?? this.cards,
//       visibleCards: visibleCards ?? this.visibleCards,
//     );
//   }

//   @override
//   List<Object?> get props => [
//         isLoading,
//         errorMessage,
//         cards,
//         visibleCards,
//       ];
// }
