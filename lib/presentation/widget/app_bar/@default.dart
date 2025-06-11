import 'package:flutter/material.dart';

class AppBarMenuItem {
  final Object label;
  final Object? action;

  const AppBarMenuItem({
    required this.label,
    this.action,
  });

  // Change this: Return a Container instead of SizedBox
  static AppBarMenuItem empty() => const AppBarMenuItem(label: SizedBox.shrink()); // Or a simple Container()

  static AppBarMenuItem back() => const AppBarMenuItem(label: Icons.arrow_back_ios_new_rounded, action: '/back');

  Widget buildLabel(BuildContext context, {required bool isTitle}) {
    final theme = Theme.of(context);

    return switch (label) {
      IconData icon => Icon(icon),
      String text => Text(
          text,
          style: isTitle
              ? theme.textTheme.titleMedium
              : theme.textTheme.bodyMedium?.copyWith(color: theme.appBarTheme.iconTheme?.color),
          textAlign: TextAlign.center,
        ),
      // If the label itself is already a widget, return it directly.
      // This is crucial if AppBarMenuItem.empty() provides a widget.
      Widget widget => widget,
      _ => const Icon(Icons.error_outline),
    };
  }
}

class DefaultAppBar extends StatelessWidget implements PreferredSizeWidget {
  final List<AppBarMenuItem> menu;

  const DefaultAppBar({
    super.key,
    required this.menu,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      title: menu.length == 1
          ? Center(child: _buildMenuContent(context, menu[0], isTitle: true))
          : Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: menu
                  .asMap()
                  .entries
                  .map((entry) {
                    final isTitleItem = _isTitle(entry.key);
                    return Expanded(
                      // Using flex: 0 and fit: FlexFit.tight for the empty slot could also work,
                      // but flex > 0 is usually what you want for distributing space.
                      // If the item is empty, it should probably take up minimal space unless it's a spacer.
                      // For truly "empty" items that shouldn't take up any flexible space,
                      // consider using a const SizedBox.shrink() directly in the Expanded child
                      // or a very small flex value.
                      flex: isTitleItem ? 3 : 1,
                      child: _buildMenuContent(
                        context,
                        entry.value,
                        isTitle: isTitleItem,
                      ),
                    );
                  })
                  .toList(),
            ),
    );
  }

  Widget _buildMenuContent(BuildContext context, AppBarMenuItem item, {required bool isTitle}) {
    // If the item is supposed to be "empty", you might want to return a constrained box
    // that doesn't interfere with the flex layout, or a very small widget.
    // The `SizedBox.shrink()` (or a `Container()` with no dimensions) is often the best.
    if (item.label is SizedBox && (item.label as SizedBox).width == 24) { // Check for your empty item specifically
      return GestureDetector(
        onTap: () => _handleTap(context, item.action),
        child: const SizedBox.shrink(), // Return a shrinked box for empty items
      );
    }

    return GestureDetector(
      onTap: () => _handleTap(context, item.action),
      child: Container(
        height: kToolbarHeight,
        alignment: Alignment.center,
        child: item.buildLabel(context, isTitle: isTitle),
      ),
    );
  }

  void _handleTap(BuildContext context, Object? action) {
    if (action == null) return;
    final navigator = Navigator.of(context);

    switch (action) {
      case String s:
        s.startsWith('/back') ? navigator.pop() : navigator.pushNamed(s);
        break;
      case Map<String, dynamic> map:
        navigator.pushNamed(map['route'], arguments: map['arguments']);
        break;
      case VoidCallback cb:
        cb();
        break;
      default:
        debugPrint('Unknown action type: $action');
    }
  }

  bool _isTitle(int index) => index == menu.length ~/ 2;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}