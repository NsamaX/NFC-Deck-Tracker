import 'package:flutter/material.dart';

import '../../theme/theme.dart';
import '../shared/list_section.dart';
import '../../constant.dart';

class SettingLanguage extends StatelessWidget {
  final List<ListSection<SettingItem>> language;

  const SettingLanguage({
    super.key,
    required this.language,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: WidgetConstant.sectionPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: language.map((category) {
          final title = category.title;
          final content = category.items;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (title != null) _buildTitle(context, title: title),
              ...content
                  .map((item) => _buildItem(context, item: item))
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
        style: theme.textTheme.bodyMedium
            ?.copyWith(color: theme.colorScheme.primary),
      ),
    );
  }

  Widget _buildItem(
    BuildContext context, {
    required SettingItem item,
  }) {
    final theme = Theme.of(context);

    final text = item.text;
    final onTap = item.onTap;
    final mark = item.mark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 40.0,
        padding: WidgetConstant.rowPadding,
        decoration: BoxDecoration(
          color: theme.appBarTheme.backgroundColor,
          border: Border(
            bottom:
                BorderSide(color: theme.colorScheme.opacityText, width: 1.0),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(text, style: theme.textTheme.bodySmall),
            if (mark)
              Icon(Icons.check_rounded,
                  size: 18.0, color: theme.colorScheme.opacityText),
          ],
        ),
      ),
    );
  }
}
