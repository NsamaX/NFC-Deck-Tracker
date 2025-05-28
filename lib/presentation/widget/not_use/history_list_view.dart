// import 'package:flutter/material.dart';
// import 'package:flutter_slidable/flutter_slidable.dart';

// import 'package:nfc_deck_tracker/core/locale/localization.dart';
// import 'package:nfc_deck_tracker/core/theme/theme.dart';

// class HistoryListViewWidget extends StatelessWidget {
//   final List<Map<String, dynamic>> section;

//   const HistoryListViewWidget({
//     super.key,
//     required this.section,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.only(top: 2.0),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: section.map((category) {
//           final title = category['title'] as String?;
//           final content = category['content'] as List;

//           return Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               if (title != null) _buildTitle(context, title),
//               ...content.map((item) => _buildItem(context, item)).toList(),
//             ],
//           );
//         }).toList(),
//       ),
//     );
//   }

//   Widget _buildTitle(BuildContext context, String title) {
//     final theme = Theme.of(context);

//     return Padding(
//       padding: const EdgeInsets.only(left: 20.0, top: 16.0, bottom: 8.0),
//       child: Text(
//         title,
//         style: theme.textTheme.bodyMedium?.copyWith(
//           color: theme.colorScheme.primary,
//         ),
//       ),
//     );
//   }

//   Widget _buildItem(BuildContext context, Map<String, dynamic> item) {
//     final theme = Theme.of(context);
//     final locale = AppLocalization.of(context);

//     final text = item['text'] as String?;
//     final info = item['info'] as String?;
//     final onTap = item['onTap'] as VoidCallback?;
//     final onDel = item['onDel'] as VoidCallback?;
//     final pop = item['pop'] is bool && item['pop'] == true;

//     final row = Container(
//       height: 40.0,
//       padding: const EdgeInsets.symmetric(horizontal: 20.0),
//       decoration: BoxDecoration(
//         color: theme.appBarTheme.backgroundColor,
//         border: Border(
//           bottom: BorderSide(color: theme.colorScheme.opacityText, width: 1.0),
//         ),
//       ),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           if (text != null)
//             Text(text, style: theme.textTheme.bodySmall),
//           Row(
//             children: [
//               if (info != null)
//                 Text(info, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.opacityText)),
//               if (info != null) const SizedBox(width: 6),
//               if (pop)
//                 Icon(Icons.arrow_outward_rounded, size: 16, color: theme.colorScheme.opacityText),
//             ],
//           ),
//         ],
//       ),
//     );

//     final tappable = GestureDetector(onTap: onTap, child: row);

//     return onDel != null
//         ? Slidable(
//             key: ValueKey(item['key']),
//             endActionPane: ActionPane(
//               motion: const DrawerMotion(),
//               children: [
//                 SlidableAction(
//                   onPressed: (_) => onDel(),
//                   backgroundColor: Colors.red,
//                   foregroundColor: Colors.white,
//                   label: locale.translate('common.button_delete'),
//                 ),
//               ],
//             ),
//             child: tappable,
//           )
//         : tappable;
//   }
// }
