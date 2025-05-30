import 'package:flutter/material.dart';

import '../../theme/theme.dart';

class LanguageListViewWidget extends StatelessWidget {
  final List<Map<String, dynamic>> language;

  const LanguageListViewWidget({
    super.key,
    required this.language,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(top: 2.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: language.map((category) {
          final title = category['title'] as String?;
          final content = category['content'] as List;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (title != null) _buildTitle(title, theme),
              ...content.map((item) => _buildItem(item, theme)).toList(),
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
        style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.primary),
      ),
    );
  }

  Widget _buildItem(Map<String, dynamic> item, ThemeData theme) {
    final text = item['text'] as String?;
    final onTap = item['onTap'] as VoidCallback?;
    final mark = item['mark'] ?? false;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 40.0,
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        decoration: BoxDecoration(
          color: theme.appBarTheme.backgroundColor,
          border: Border(
            bottom: BorderSide(color: theme.colorScheme.opacityText, width: 1.0),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            if (text != null)
              Text(text, style: theme.textTheme.bodySmall),
            if (mark)
              Icon(Icons.check_rounded, size: 18.0, color: theme.colorScheme.opacityText),
          ],
        ),
      ),
    );
  }
}
