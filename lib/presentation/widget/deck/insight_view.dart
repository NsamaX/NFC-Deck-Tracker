import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import 'package:nfc_deck_tracker/domain/entity/usage_card_stats.dart';
import 'package:nfc_deck_tracker/presentation/dependencies.dart';

import '../../bloc/reader/bloc.dart';
import '../../bloc/record/bloc.dart';
import '../../bloc/tracker/bloc.dart';
import '../../bloc/usage_card/bloc.dart';
import '../../locale/localization.dart';

import '../specific/history_list_view.dart';

import 'insight_chart.dart';
import 'insight_summary.dart';
import '../shared/list_section.dart';

class DeckInsightView extends StatefulWidget {
  final AppLocalization locale;

  const DeckInsightView({
    super.key,
    required this.locale,
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
      context.read<RecordBloc>().add(FetchRecordEvent(
            userId: PresentationScope.read(context).userId,
            deckId: context.read<TrackerBloc>().state.originalDeck.deckId,
          ));

      _hasLoaded = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final stat = context.read<UsageCardBloc>().state.stat;

    return ListView(
      children: [
        _buildChart(stat),
        _buildSummary(),
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

  Widget _buildSummary() {
    return DeckInsightSummary(
        summary: context.read<UsageCardBloc>().state.summary);
  }

  Widget _buildHistory(List<UsageCardStats> cardStats) {
    return BlocBuilder<RecordBloc, RecordState>(
      builder: (context, state) {
        return HistoryListView(
          section: [
            ListSection(
              title: widget.locale.translate('page_deck_tracker.history_title'),
              items: state.records.map((record) {
                return HistoryItem(
                  key: record.recordId,
                  info: DateFormat('HH:mm:ss').format(record.createdAt!),
                  text: DateFormat('yyyy-MM-dd').format(record.createdAt!),
                  onTap: () {
                    context
                        .read<RecordBloc>()
                        .add(FindRecordEvent(recordId: record.recordId));
                    context.read<RecordBloc>().add(GetCardFromRecordEvent(
                        recordId: record.recordId,
                        deck: context.read<TrackerBloc>().state.originalDeck));
                    context.read<ReaderBloc>().add(SetReadedCardsEvent(
                        readedCards: context.read<RecordBloc>().state.cards));
                    context
                        .read<TrackerBloc>()
                        .add(LoadDeckFromRecordEvent(record: record));
                    context.read<UsageCardBloc>().add(CalculateUsageCardEvent(
                        deck: context.read<TrackerBloc>().state.originalDeck,
                        record: record));
                  },
                  onDelete: () {
                    context.read<RecordBloc>().add(DeleteRecordEvent(
                          userId: PresentationScope.read(context).userId,
                          recordId: record.recordId,
                        ));
                  },
                  popAfterTap: true,
                );
              }).toList(),
            ),
          ],
        );
      },
    );
  }
}
