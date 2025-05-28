// import 'dart:math';

// import 'package:fl_chart/fl_chart.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';

// import 'package:nfc_deck_tracker/core/locale/localization.dart';
// import 'package:nfc_deck_tracker/domain/entity/usage_card_stats.dart';

// class DeckInsightChartWidget extends StatelessWidget {
//   final List<UsageCardStats> cardStats;

//   const DeckInsightChartWidget({
//     super.key,
//     required this.cardStats,
//   });

//   static const double _barWidth = 40.0;
//   static const double _chartHeight = 400.0;
//   static const int _minBars = 8;
//   static const int _maxY = 10;

//   @override
//   Widget build(BuildContext context) {
//     final locale = AppLocalization.of(context);
//     final theme = Theme.of(context);
//     final mediaQuery = MediaQuery.of(context);

//     final data = _generateData(mediaQuery);
//     final drawCounts = data.map((e) => e.drawCount).toList();
//     final returnCounts = data.map((e) => e.returnCount).toList();

//     if (cardStats.isEmpty) {
//       return Padding(
//         padding: const EdgeInsets.symmetric(vertical: 24),
//         child: Center(
//           child: Text(
//             locale.translate('page_deck_tracker.no_insight'),
//             style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey),
//           ),
//         ),
//       );
//     }

//     return Column(
//       children: [
//         const SizedBox(height: 8.0),
//         _buildLegend(context),
//         const SizedBox(height: 8.0),
//         _buildChart(context, draw: drawCounts, ret: returnCounts, data: data),
//       ],
//     );
//   }

//   List<UsageCardStats> _generateData(MediaQueryData mediaQuery) {
//     final screenWidth = mediaQuery.size.width;
//     final maxBars = max((screenWidth / _barWidth).floor(), _minBars);

//     final cleanedData = cardStats.where((e) => e.cardName.isNotEmpty).toList();

//     return cleanedData.length < maxBars
//         ? [
//             ...cleanedData,
//             ...List.filled(
//               maxBars - cleanedData.length,
//               const UsageCardStats(cardName: '', drawCount: 0, returnCount: 0),
//             )
//           ]
//         : cleanedData;
//   }

//   Widget _buildLegend(BuildContext context) {
//     final locale = AppLocalization.of(context);
//     final theme = Theme.of(context);

//     return Row(
//       mainAxisAlignment: MainAxisAlignment.end,
//       children: [
//         _buildLegendItem(
//           text: locale.translate('page_deck_tracker.draw'),
//           color: CupertinoColors.activeBlue,
//           theme: theme,
//         ),
//         const SizedBox(width: 12),
//         _buildLegendItem(
//           text: locale.translate('page_deck_tracker.return'),
//           color: CupertinoColors.destructiveRed,
//           theme: theme,
//         ),
//       ],
//     );
//   }

//   Widget _buildLegendItem({
//     required String text,
//     required Color color,
//     required ThemeData theme,
//   }) {
//     return Row(
//       children: [
//         Container(
//           width: 12,
//           height: 12,
//           decoration: BoxDecoration(color: color, shape: BoxShape.circle),
//         ),
//         const SizedBox(width: 8),
//         Text(text, style: theme.textTheme.bodySmall),
//       ],
//     );
//   }

//   Widget _buildChart(
//     BuildContext context, {
//     required List<int> draw,
//     required List<int> ret,
//     required List<UsageCardStats> data,
//   }) {
//     final theme = Theme.of(context);
//     final axisColor = theme.appBarTheme.backgroundColor ?? Colors.grey;

//     return Row(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         _buildYAxis(theme),
//         const SizedBox(width: 8),
//         Container(width: 1.2, height: _chartHeight - 54, color: axisColor),
//         _buildChartBody(context, draw: draw, ret: ret, data: data),
//       ],
//     );
//   }

//   Widget _buildYAxis(ThemeData theme) {
//     final spacing = _chartHeight / _maxY - 21.4;

//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.end,
//       children: List.generate(_maxY, (i) {
//         final text = (_maxY - i).toString();
//         return Column(
//           children: [
//             Text(text, style: theme.textTheme.bodySmall),
//             SizedBox(height: spacing),
//           ],
//         );
//       }),
//     );
//   }

//   Widget _buildChartBody(
//     BuildContext context, {
//     required List<int> draw,
//     required List<int> ret,
//     required List<UsageCardStats> data,
//   }) {
//     return Expanded(
//       child: Padding(
//         padding: const EdgeInsets.only(top: 6),
//         child: SingleChildScrollView(
//           scrollDirection: Axis.horizontal,
//           child: SizedBox(
//             width: _barWidth * draw.length,
//             height: _chartHeight,
//             child: BarChart(
//               BarChartData(
//                 barGroups: List.generate(
//                   draw.length,
//                   (i) => BarChartGroupData(
//                     x: i,
//                     barsSpace: 6,
//                     barRods: [
//                       BarChartRodData(
//                         toY: min(draw[i].toDouble(), _maxY.toDouble()),
//                         color: CupertinoColors.activeBlue,
//                         width: 4,
//                       ),
//                       BarChartRodData(
//                         toY: min(ret[i].toDouble(), _maxY.toDouble()),
//                         color: CupertinoColors.destructiveRed,
//                         width: 4,
//                       ),
//                     ],
//                   ),
//                 ),
//                 titlesData: FlTitlesData(
//                   bottomTitles: AxisTitles(
//                     sideTitles: SideTitles(
//                       showTitles: true,
//                       reservedSize: 60,
//                       getTitlesWidget: (value, _) =>
//                           _buildRotatedLabel(context, data, value.toInt()),
//                     ),
//                   ),
//                   leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
//                   topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
//                   rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
//                 ),
//                 gridData: FlGridData(
//                   show: true,
//                   drawVerticalLine: true,
//                   drawHorizontalLine: true,
//                   verticalInterval: 1,
//                   horizontalInterval: 1,
//                   getDrawingHorizontalLine: (_) =>
//                       FlLine(color: Theme.of(context).dividerColor, strokeWidth: 1.2),
//                   getDrawingVerticalLine: (_) =>
//                       FlLine(color: Theme.of(context).dividerColor, strokeWidth: 1.2),
//                 ),
//                 borderData: FlBorderData(
//                   show: true,
//                   border: Border(
//                     bottom: BorderSide(color: Theme.of(context).dividerColor, width: 1.2),
//                     left: BorderSide.none,
//                   ),
//                 ),
//                 maxY: _maxY.toDouble(),
//                 minY: 0,
//                 barTouchData: BarTouchData(enabled: false),
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildRotatedLabel(
//     BuildContext context,
//     List<UsageCardStats> data,
//     int index,
//   ) {
//     final theme = Theme.of(context);

//     if (index >= data.length) return const SizedBox();

//     final name = data[index].cardName;
//     final display = name.length > 10 ? '${name.substring(0, 10)}...' : name;

//     return Padding(
//       padding: const EdgeInsets.only(top: 12),
//       child: Transform.rotate(
//         angle: pi / 4,
//         child: Text(
//           display,
//           style: theme.textTheme.bodySmall,
//           overflow: TextOverflow.ellipsis,
//         ),
//       ),
//     );
//   }
// }
