import 'package:flutter/material.dart';

import '../../locale/localization.dart';

class DeckSwitchMode extends StatelessWidget {
  final bool isAnalyzeModeEnabled;
  final ValueChanged<bool> onSelected;

  const DeckSwitchMode({
    super.key,
    required this.isAnalyzeModeEnabled,
    required this.onSelected,
  });

  static const _radius = BorderRadius.all(Radius.circular(12.0));
  static const _height = 40.0;
  static const _width = 160.0;
  static const _animationDuration = Duration(milliseconds: 200);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final locale = AppLocalization.of(context);

    final items = [
      locale.translate('page_deck_tracker.switch_mode_deck'),
      locale.translate('page_deck_tracker.switch_mode_insight'),
    ];

    return SizedBox(
      width: _width * 2,
      height: _height,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            decoration: BoxDecoration(
              color: theme.appBarTheme.backgroundColor,
              borderRadius: _radius,
            ),
          ),
          AnimatedAlign(
            duration: _animationDuration,
            alignment: isAnalyzeModeEnabled ? Alignment.centerRight : Alignment.centerLeft,
            child: Container(
              width: _width,
              height: _height,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: _radius,
              ),
            ),
          ),
          Row(
            children: List.generate(items.length, (index) {
              final isActive = (index == (isAnalyzeModeEnabled ? 1 : 0));
              return Expanded(
                child: InkWell(
                  onTap: () => onSelected(index == 1),
                  borderRadius: _radius,
                  child: Center(
                    child: Text(
                      items[index],
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: isActive
                            ? theme.scaffoldBackgroundColor
                            : theme.textTheme.titleMedium?.color,
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
