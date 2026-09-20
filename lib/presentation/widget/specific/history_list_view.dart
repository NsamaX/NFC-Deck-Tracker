import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import '../../locale/localization.dart';
import '../../theme/theme.dart';
import '../shared/list_section.dart';
import '../../constant.dart';

class HistoryListView extends StatelessWidget {
  final List<ListSection<HistoryItem>> section;

  const HistoryListView({
    super.key,
    required this.section,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: WidgetConstant.sectionPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: section.map((category) {
          final title = category.title;
          final content = category.items;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (title != null) _buildTitle(context, title),
              ...content.map((item) => _buildItem(context, item)).toList(),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTitle(BuildContext context, String title) {
    final theme = Theme.of(context);

    return Padding(
      padding: WidgetConstant.sectionTitlePadding,
      child: Text(
        title,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: theme.appBarTheme.iconTheme?.color,
        ),
      ),
    );
  }

  Widget _buildItem(BuildContext context, HistoryItem item) {
    final theme = Theme.of(context);
    final locale = AppLocalization.of(context);

    final text = item.text;
    final info = item.info;
    final onTap = item.onTap;
    final onDel = item.onDelete;
    final pop = item.popAfterTap;

    final row = Container(
      height: 40.0,
      padding: WidgetConstant.rowPadding,
      decoration: BoxDecoration(
        color: theme.appBarTheme.backgroundColor,
        border: Border(
          bottom: BorderSide(color: theme.colorScheme.opacityText, width: 1.0),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(text, style: theme.textTheme.bodySmall),
          Row(
            children: [
              if (info != null)
                Text(info,
                    style: theme.textTheme.bodySmall
                        ?.copyWith(color: theme.colorScheme.opacityText)),
              if (info != null) const SizedBox(width: 6),
              if (pop)
                Icon(Icons.arrow_outward_rounded,
                    size: 16, color: theme.colorScheme.opacityText),
            ],
          ),
        ],
      ),
    );

    final tappable = GestureDetector(onTap: onTap, child: row);

    return onDel != null
        ? Slidable(
            key: ValueKey(item.key),
            endActionPane: ActionPane(
              motion: const DrawerMotion(),
              children: [
                SlidableAction(
                  onPressed: (_) => onDel(),
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  label: locale.translate('common.button_delete'),
                ),
              ],
            ),
            child: tappable,
          )
        : tappable;
  }
}
