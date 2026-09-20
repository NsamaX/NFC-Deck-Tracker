import 'package:flutter/material.dart';

import '../../theme/theme.dart';
import '../shared/list_section.dart';
import '../../constant.dart';

class SettingSection extends StatelessWidget {
  final List<ListSection<SettingItem>> section;

  const SettingSection({
    super.key,
    required this.section,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: WidgetConstant.sectionPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: section.map((cat) {
          final title = cat.title;
          final content = cat.items;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (title != null) _buildTitle(context, title: title),
              ...content
                  .map((item) => _buildContentItem(context, item: item))
                  .toList(),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTitle(
    BuildContext context, {
    required String title,
  }) {
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

  Widget _buildContentItem(
    BuildContext context, {
    required SettingItem item,
  }) {
    final theme = Theme.of(context);

    final icon = item.icon;
    final text = item.text;
    final info = item.info;
    final route = item.route;
    final onTap = item.onTap;

    return GestureDetector(
      onTap: () {
        if (route != null) Navigator.of(context).pushNamed(route);
        if (onTap != null) onTap();
      },
      child: Container(
        height: 40.0,
        padding: WidgetConstant.rowPadding,
        decoration: BoxDecoration(
          color: theme.appBarTheme.backgroundColor,
          border: Border(
            bottom: BorderSide(
              color: theme.colorScheme.opacityText,
              width: 1.0,
            ),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                if (icon != null) Icon(icon),
                if (icon != null) const SizedBox(width: 12.0),
                Text(text, style: theme.textTheme.bodySmall),
              ],
            ),
            Row(
              children: [
                if (info != null)
                  Text(info,
                      style: theme.textTheme.bodySmall
                          ?.copyWith(color: theme.colorScheme.opacityText)),
                if (info != null) const SizedBox(width: 6.0),
                if (route != null)
                  Icon(Icons.arrow_forward_ios_rounded,
                      color: theme.colorScheme.opacityText),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
