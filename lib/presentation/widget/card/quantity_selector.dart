import 'package:flutter/material.dart';

class CardQuantitySelector extends StatelessWidget {
  final ValueChanged<int> onSelected;
  final int quantityCount;
  final int selectedQuantity;

  const CardQuantitySelector({
    super.key,
    required this.onSelected,
    required this.quantityCount,
    required this.selectedQuantity,
  });

  static const double _width = 60.0;
  static const double _height = 40.0;
  static const double _spacing = 6.6;
  static const double _radius = 12.0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (quantityCount <= 0) return const SizedBox.shrink();

    final totalWidth = _width * quantityCount + _spacing * (quantityCount - 1);

    return Column(
      children: [
        const SizedBox(height: 24),
        SizedBox(
          height: _height + 20.0,
          child: Stack(
            children: [
              Container(
                width: totalWidth,
                height: _height,
                decoration: BoxDecoration(
                  color: theme.appBarTheme.backgroundColor,
                  borderRadius: BorderRadius.circular(_radius),
                ),
              ),
              AnimatedPositioned(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                left: _calculateLeft(selectedQuantity - 1),
                child: Container(
                  width: _width,
                  height: _height,
                  decoration: BoxDecoration(
                    color: theme.textTheme.titleMedium?.color,
                    borderRadius: BorderRadius.circular(_radius),
                  ),
                ),
              ),
              SizedBox(
                width: totalWidth,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: List.generate(
                    quantityCount * 2 - 1,
                    (index) => index.isOdd
                        ? Container(
                            width: 0.8,
                            height: _height * 0.6,
                            color: theme.dividerColor,
                          )
                        : _buildQuantityItem(
                            context,
                            index: index ~/ 2,
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  double _calculateLeft(int selectedIndex) => selectedIndex * _width + selectedIndex * _spacing;

  Widget _buildQuantityItem(BuildContext context, {required int index}) {
    final theme = Theme.of(context);
    final isSelected = selectedQuantity == index + 1;

    final textStyle = theme.textTheme.titleMedium?.copyWith(
      color: isSelected
          ? theme.scaffoldBackgroundColor
          : theme.textTheme.titleMedium?.color,
    );

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => onSelected(index + 1),
      child: SizedBox(
        width: _width,
        height: _height,
        child: Center(
          child: AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 400),
            style: textStyle ?? const TextStyle(),
            child: Text('${index + 1}'),
          ),
        ),
      ),
    );
  }
}
