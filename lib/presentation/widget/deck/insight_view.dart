import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import 'package:nfc_deck_tracker/domain/entity/usage_card_stats.dart';

import '../../cubit/reader_cubit.dart';
import '../../cubit/tracker_cubit.dart';
import '../../cubit/record_cubit.dart';
import '../../cubit/usage_card_cubit.dart';
import '../../locale/localization.dart';

import '../specific/history_list_view.dart';

import 'insight_chart.dart';
import 'insight_summary.dart';

class DeckInsightView extends StatefulWidget {
  final AppLocalization locale;
  final ReaderCubit readerCubit;
  final TrackerCubit trackerCubit;
  final RecordCubit recordCubit;
  final UsageCardCubit usageCardCubit;
  final String userId;

  const DeckInsightView({
    super.key,
    required this.locale,
    required this.readerCubit,
    required this.trackerCubit,
    required this.recordCubit,
    required this.usageCardCubit,
    required this.userId,
  });

  @override
  State<DeckInsightView> createState() => _DeckInsightViewWidgetState();
}

class _DeckInsightViewWidgetState extends State<DeckInsightView> {
  bool _hasLoaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!_hasLoaded) {
      widget.recordCubit.fetchRecord(
        userId: widget.userId,
        deckId: widget.trackerCubit.state.originalDeck.deckId!,
      );

      _hasLoaded = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final stat = widget.usageCardCubit.state.stat;

    return ListView(
      children: [
        _buildChart(stat),
        _buildSummary(stat),
        _buildHistory(stat),
      ],
    );
  }

  Widget _buildChart(List<UsageCardStats> cardStats) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(6.0, 0.0, 16.0, 0.0),
      child: DeckInsightChart(cardStats: cardStats),
    );
  }

  Widget _buildSummary(List<UsageCardStats> cardStats) {
    return DeckInsightSummary(
      initialDeck: widget.trackerCubit.state.originalDeck,
      allRecord: widget.recordCubit.state.records,
      currentRecord: widget.recordCubit.state.currentRecord,
      usageCardStat: cardStats,
      selectRecord: (context, recordId) {
        widget.recordCubit.findRecord(recordId: recordId);
      },
    );
  }

  Widget _buildHistory(List<UsageCardStats> cardStats) {
    return BlocBuilder<RecordCubit, RecordState>(
      builder: (context, state) {
        return HistoryListView(
          section: [
            {
              'title': widget.locale.translate('page_deck_tracker.history_title'),
              'content': state.records.map((record) {
                return {
                  'key': record.recordId,
                  'info': DateFormat('HH:mm:ss').format(record.createdAt),
                  'text': DateFormat('yyyy-MM-dd').format(record.createdAt),
                  'onTap': () {
                    widget.recordCubit.findRecord(recordId: record.recordId);
                    final cards = widget.recordCubit.getCardFromRecord(
                      recordId: record.recordId,
                      deck: widget.trackerCubit.state.originalDeck,
                    );
                    widget.readerCubit.setScannedCard(scannedCards: cards);
                  },
                  'onDel': () {
                    widget.recordCubit.removeRecord(
                      userId: widget.userId,
                      recordId: record.recordId,
                    );
                  },
                  'pop': true,
                };
              }).toList(),
            }
          ],
        );
      },
    );
  }
}
