import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:nfc_deck_tracker/domain/entity/usage_card_stats.dart';

import '../../cubit/application_cubit.dart';
import '../../cubit/reader_cubit.dart';
import '../../cubit/tracker_cubit.dart';
import '../../cubit/record_cubit.dart';
import '../../cubit/usage_card_cubit.dart';
import '../../locale/localization.dart';

import 'deck_insight_chart.dart';
import 'deck_insight_summary.dart';
import 'history_list_view.dart';

class DeckInsightViewWidget extends StatefulWidget {
  const DeckInsightViewWidget({super.key});

  @override
  State<DeckInsightViewWidget> createState() => _DeckInsightViewWidgetState();
}

class _DeckInsightViewWidgetState extends State<DeckInsightViewWidget> {
  bool _didLoad = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_didLoad) {
      final trackerCubit = context.read<TrackerCubit>();
      final recordCubit = context.read<RecordCubit>();
      final usageCardCubit = context.read<UsageCardCubit>();

      usageCardCubit.loadUsageStats(
        deck: trackerCubit.state.originalDeck,
        record: recordCubit.state.currentRecord,
      );

      _didLoad = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final locale = AppLocalization.of(context);
    final theme = Theme.of(context);
    final mediaQuery = MediaQuery.of(context);

    final applicationCubit = context.read<ApplicationCubit>();
    final readerCubit = context.read<ReaderCubit>();
    final trackerCubit = context.read<TrackerCubit>();
    final recordCubit = context.read<RecordCubit>();
    final userId = FirebaseAuth.instance.currentUser?.uid ?? '';

    return BlocBuilder<UsageCardCubit, UsageCardState>(
      builder: (context, state) {
        if (state.isProcessing) {
          return const Center(child: CircularProgressIndicator());
        }

        return ListView(
          children: [
            _buildChart(locale, theme, mediaQuery, state.stat),
            _buildSummary(locale, theme, trackerCubit, recordCubit, state.stat),
            if (recordCubit.state.records.isNotEmpty)
              _buildHistory(locale, theme, readerCubit, trackerCubit, recordCubit, applicationCubit, userId),
          ],
        );
      },
    );
  }

  Widget _buildChart(
    AppLocalization locale,
    ThemeData theme,
    MediaQueryData mediaQuery,
    List<UsageCardStats> cardStats,
  ) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(6.0, 0.0, 16.0, 0.0),
      child: DeckInsightChart(
        cardStats: cardStats,
      ),
    );
  }

  Widget _buildSummary(
    AppLocalization locale,
    ThemeData theme,
    TrackerCubit trackerCubit,
    RecordCubit recordCubit,
    List<UsageCardStats> cardStats,
  ) {
    return DeckInsightSummary(
      initialDeck: trackerCubit.state.originalDeck,
      allRecord: recordCubit.state.records,
      currentRecord: recordCubit.state.currentRecord,
      usageCardStat: cardStats,
      selectRecord: (context, recordId) {
        recordCubit.findRecord(recordId: recordId);
      },
    );
  }

  Widget _buildHistory(
    AppLocalization locale,
    ThemeData theme,
    ReaderCubit readerCubit,
    TrackerCubit trackerCubit,
    RecordCubit recordCubit,
    ApplicationCubit applicationCubit,
    String userId,
  ) {
    return HistoryListView(
      section: [
        {
          'title': locale.translate('page_deck_tracker.history_title'),
          'content': recordCubit.state.records.map((record) {
            return {
              'key': record.recordId,
              'info': DateFormat('HH:mm:ss').format(record.createdAt),
              'text': DateFormat('yyyy-MM-dd').format(record.createdAt),
              'onTap': () {
                recordCubit.findRecord(recordId: record.recordId);
                final cards = recordCubit.getCardFromRecord(
                  recordId: record.recordId,
                  deck: trackerCubit.state.originalDeck,
                );
                readerCubit.setScannedCard(scannedCards: cards);
              },
              'onDel': () => recordCubit.removeRecord(
                userId: userId,
                recordId: record.recordId,
              ),
              'pop': true,
            };
          }).toList(),
        }
      ],
    );
  }
}
