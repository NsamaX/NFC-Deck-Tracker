import 'package:flutter/material.dart';

class AppBarMenuItem {
  final Object label;
  final Object? action;

  const AppBarMenuItem({required this.label, this.action});

  static AppBarMenuItem empty() => const AppBarMenuItem(label: SizedBox(width: 24));

  static AppBarMenuItem back() => const AppBarMenuItem(label: Icons.arrow_back_ios_new_rounded, action: '/back');

  Widget buildLabel(BuildContext context, {required bool isTitle}) {
    final theme = Theme.of(context);

    return switch (label) {
      IconData icon => Icon(icon),
      String text => Text(
          text,
          style: isTitle
              ? theme.textTheme.titleMedium
              : theme.textTheme.bodyMedium?.copyWith(
                  color: theme.appBarTheme.iconTheme?.color),
          textAlign: TextAlign.center,
        ),
      Widget widget => widget,
      _ => const Icon(Icons.error_outline),
    };
  }
}

class AppBarWidget extends StatelessWidget implements PreferredSizeWidget {
  final List<AppBarMenuItem> menu;

  const AppBarWidget({super.key, required this.menu});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      title: menu.length == 1
          ? Center(child: _buildMenu(context, menu[0], isTitle: true))
          : Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: menu
                  .asMap()
                  .entries
                  .map((entry) => _buildMenu(
                        context,
                        entry.value,
                        isTitle: _isTitle(entry.key),
                      ))
                  .toList(),
            ),
    );
  }

  Widget _buildMenu(BuildContext context, AppBarMenuItem item, {required bool isTitle}) {
    return GestureDetector(
      onTap: () => _handleTap(context, item.action),
      child: SizedBox(
        width: isTitle ? 142.0 : 42.0,
        height: kToolbarHeight,
        child: Center(
          child: item.buildLabel(context, isTitle: isTitle),
        ),
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
