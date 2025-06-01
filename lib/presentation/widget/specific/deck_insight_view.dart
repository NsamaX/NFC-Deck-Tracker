// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:intl/intl.dart';
// import 'package:firebase_auth/firebase_auth.dart';

// import 'package:nfc_deck_tracker/core/locale/localization.dart';

// import '../../cubit/application_cubit.dart';
// import '../../cubit/reader_cubit.dart';
// import '../../cubit/tracker_cubit.dart';
// import '../../cubit/record_cubit.dart';

// import 'deck_insight_chart.dart';
// import 'deck_insight_summary.dart';
// import 'history_list_view.dart';

// class DeckInsightViewWidget extends StatelessWidget {
//   const DeckInsightViewWidget({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final locale = AppLocalization.of(context);
//     final theme = Theme.of(context);
//     final mediaQuery = MediaQuery.of(context);

//     final applicationCubit = context.read<ApplicationCubit>();
//     final readerCubit = context.read<ReaderCubit>();
//     final trackerCubit = context.read<TrackerCubit>();
//     final recordCubit = context.read<RecordCubit>();

//     final currentRecord = recordCubit.state.currentRecord;
//     final userId = FirebaseAuth.instance.currentUser?.uid ?? '';

//     return FutureBuilder(
//       future: trackerCubit.calculateDrawAndReturnCountsWithDetails(record: currentRecord),
//       builder: (context, snapshot) {
//         if (!snapshot.hasData) {
//           return const Center(child: CircularProgressIndicator());
//         }

//         final cardStats = snapshot.data!;

//         return ListView(
//           children: [
//             _buildChart(locale, theme, mediaQuery, cardStats),
//             _buildSummary(locale, theme, trackerCubit, recordCubit, cardStats),
//             if (recordCubit.state.records.isNotEmpty)
//               _buildHistory(
//                 locale,
//                 theme,
//                 readerCubit,
//                 trackerCubit,
//                 recordCubit,
//                 applicationCubit,
//                 userId,
//               ),
//           ],
//         );
//       },
//     );
//   }

//   Widget _buildChart(
//     AppLocalization locale,
//     ThemeData theme,
//     MediaQueryData mediaQuery,
//     List cardStats,
//   ) {
//     return Padding(
//       padding: const EdgeInsets.fromLTRB(6.0, 0.0, 16.0, 0.0),
//       child: DeckInsightChartWidget(
//         cardStats: cardStats,
//       ),
//     );
//   }

//   Widget _buildSummary(
//     AppLocalization locale,
//     ThemeData theme,
//     TrackerCubit trackerCubit,
//     RecordCubit recordCubit,
//     List cardStats,
//   ) {
//     return DeckInsightSummaryWidget(
//       initialDeck: trackerCubit.state.originalDeck,
//       allRecord: recordCubit.state.records,
//       currentRecord: recordCubit.state.currentRecord,
//       usageCardStat: cardStats,
//       selectRecord: (context, recordId) {
//         recordCubit.findRecord(recordId: recordId);
//       },
//     );
//   }

//   Widget _buildHistory(
//     AppLocalization locale,
//     ThemeData theme,
//     ReaderCubit readerCubit,
//     TrackerCubit trackerCubit,
//     RecordCubit recordCubit,
//     ApplicationCubit applicationCubit,
//     String userId,
//   ) {
//     return HistoryListViewWidget(
//       section: [
//         {
//           'title': locale.translate('page_deck_tracker.history_title'),
//           'content': recordCubit.state.records.map((record) {
//             return {
//               'key': record.recordId,
//               'info': DateFormat('HH:mm:ss').format(record.createdAt),
//               'text': DateFormat('yyyy-MM-dd').format(record.createdAt),
//               'onTap': () async {
//                 // await recordCubit.findRecord(recordId: record.recordId);
//                 final cards = await recordCubit.getCardFromRecord(
//                   deck: trackerCubit.state.originalDeck,
//                 );
//                 readerCubit.setScannedCard(scannedCards: cards);
//               },
//               'onDel': () => recordCubit.removeRecord(
//                 userId: userId,
//                 recordId: record.recordId,
//               ),
//               'pop': true,
//             };
//           }).toList(),
//         }
//       ],
//     );
//   }
// }
