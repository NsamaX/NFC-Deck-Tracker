import 'package:flutter/material.dart';

import '../../theme/theme.dart';

class SettingsSectionWidget extends StatelessWidget {
  final List<Map<String, dynamic>> section;

  const SettingsSectionWidget({
    super.key,
    required this.section,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(top: 2.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: section.map((cat) {
          final title = cat['title'] as String?;
          final content = cat['content'] as List;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (title != null) _buildTitle(title, theme),
              ...content.map((item) => _buildContentItem(context, item, theme)).toList(),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTitle(String title, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(left: 20.0, top: 16.0, bottom: 8.0),
      child: Text(
        title,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.primary,
        ),
      ),
    );
  }

  Widget _buildContentItem(
    BuildContext context,
    Map<String, dynamic> item,
    ThemeData theme,
  ) {
    final icon  = item['icon']  as IconData?;
    final text  = item['text']  as String?;
    final info  = item['info']  as String?;
    final route = item['route'] as String?;
    final onTap = item['onTap'] as VoidCallback?;

    return GestureDetector(
      onTap: () {
        if (route != null) Navigator.of(context).pushNamed(route);
        if (onTap != null) onTap();
      },
      child: Container(
        height: 40.0,
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
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
                if (text != null) Text(text, style: theme.textTheme.bodySmall),
              ],
            ),
            Row(
              children: [
                if (info != null)
                  Text(info, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.opacityText)),
                if (info != null) const SizedBox(width: 6.0),
                if (route != null)
                  Icon(Icons.arrow_forward_ios_rounded, color: theme.colorScheme.opacityText),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
