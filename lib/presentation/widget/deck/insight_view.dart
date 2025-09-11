import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import 'package:nfc_deck_tracker/domain/entity/usage_card_stats.dart';

import '../../bloc/reader/bloc.dart';
import '../../bloc/record/bloc.dart';
import '../../bloc/tracker/bloc.dart';
import '../../bloc/usage_card/bloc.dart';
import '../../locale/localization.dart';

import '../specific/history_list_view.dart';

import 'insight_chart.dart';
import 'insight_summary.dart';

class DeckInsightView extends StatefulWidget {
  final AppLocalization locale;
  final ReaderBloc readerBloc;
  final TrackerBloc trackerBloc;
  final RecordBloc recordBloc;
  final UsageCardBloc usageCardBloc;
  final String userId;

  const DeckInsightView({
    super.key,
    required this.locale,
    required this.readerBloc,
    required this.trackerBloc,
    required this.recordBloc,
    required this.usageCardBloc,
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
      widget.recordBloc.add(FetchRecordEvent(
        userId: widget.userId,
        deckId: widget.trackerBloc.state.originalDeck.deckId!,
      ));

      _hasLoaded = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final stat = widget.usageCardBloc.state.stat;

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
      initialDeck: widget.trackerBloc.state.originalDeck,
      allRecord: widget.recordBloc.state.records,
      currentRecord: widget.recordBloc.state.currentRecord,
      usageCardStat: cardStats,
      selectRecord: (context, recordId) {
        widget.recordBloc.add(FindRecordEvent(recordId: recordId));
      },
    );
  }

  Widget _buildHistory(List<UsageCardStats> cardStats) {
    return BlocBuilder<RecordBloc, RecordState>(
      builder: (context, state) {
        return HistoryListView(
          section: [
            {
              'title': widget.locale.translate('page_deck_tracker.history_title'),
              'content': state.records.map((record) {
                return {
                  'key': record.recordId,
                  'info': DateFormat('HH:mm:ss').format(record.createdAt!),
                  'text': DateFormat('yyyy-MM-dd').format(record.createdAt!),
                  'onTap': () {
                    widget.recordBloc.add(FindRecordEvent(recordId: record.recordId));
                    widget.recordBloc.add(GetCardFromRecordEvent(recordId: record.recordId, deck: widget.trackerBloc.state.originalDeck));
                    widget.readerBloc.add(SetReadedCardsEvent(readedCards: widget.recordBloc.state.cards));
                    widget.trackerBloc.add(LoadDeckFromRecordEvent(record: record));
                    widget.usageCardBloc.add(CalculateUsageCardEvent(deck: widget.trackerBloc.state.originalDeck, record: record));
                  },
                  'onDel': () {
                    widget.recordBloc.add(DeleteRecordEvent(
                      userId: widget.userId,
                      recordId: record.recordId,
                    ));
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
