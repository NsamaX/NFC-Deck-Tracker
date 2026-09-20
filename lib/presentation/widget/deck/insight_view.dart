import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import 'package:nfc_deck_tracker/domain/entity/usage_card_stats.dart';
import 'package:nfc_deck_tracker/presentation/dependencies.dart';

import '../../bloc/tracker/bloc.dart';
import '../../locale/localization.dart';

import '../specific/history_list_view.dart';

import 'insight_chart.dart';
import 'insight_summary.dart';
import '../shared/list_section.dart';

class DeckInsightView extends StatefulWidget {
  const DeckInsightView({
    super.key,
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
      context.read<TrackerBloc>().add(FetchRecordsEvent(
            userId: PresentationScope.read(context).userId,
          ));

      _hasLoaded = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final stat = context.watch<TrackerBloc>().state.usageStats;

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
        summary: context.watch<TrackerBloc>().state.summary);
  }

  Widget _buildHistory(List<UsageCardStats> cardStats) {
    return BlocBuilder<TrackerBloc, TrackerState>(
      builder: (context, state) {
        return HistoryListView(
          section: [
            ListSection(
              title: AppLocalization.of(context)
                  .translate('page_deck_tracker.history_title'),
              items: state.records.map((record) {
                return HistoryItem(
                  key: record.recordId,
                  info: DateFormat('HH:mm:ss').format(record.createdAt!),
                  text: DateFormat('yyyy-MM-dd').format(record.createdAt!),
                  onTap: () => context
                      .read<TrackerBloc>()
                      .add(SelectRecordEvent(recordId: record.recordId)),
                  onDelete: () {
                    context.read<TrackerBloc>().add(DeleteRecordEvent(
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
