import 'package:flutter/material.dart';

sealed class MenuAction {
  const MenuAction();

  const factory MenuAction.back() = _BackAction;
  const factory MenuAction.route(String route, {Object? arguments}) =
      _RouteAction;
  const factory MenuAction.callback(VoidCallback callback) = _CallbackAction;

  void run(BuildContext context) {
    final navigator = Navigator.of(context);
    switch (this) {
      case _BackAction():
        navigator.pop();
      case _RouteAction(:final route, :final arguments):
        navigator.pushNamed(route, arguments: arguments);
      case _CallbackAction(:final callback):
        callback();
    }
  }
}

class _BackAction extends MenuAction {
  const _BackAction();
}

class _RouteAction extends MenuAction {
  final String route;
  final Object? arguments;
  const _RouteAction(this.route, {this.arguments});
}

class _CallbackAction extends MenuAction {
  final VoidCallback callback;
  const _CallbackAction(this.callback);
}

class AppBarMenuItem {
  final Object label;
  final MenuAction? action;
  final bool enabled;

  const AppBarMenuItem({
    required this.label,
    this.action,
    this.enabled = true,
  });

  static AppBarMenuItem empty() =>
      const AppBarMenuItem(label: SizedBox.shrink());

  static AppBarMenuItem back() => const AppBarMenuItem(
      label: Icons.arrow_back_ios_new_rounded, action: MenuAction.back());

  Widget buildLabel(BuildContext context, {required bool isTitle}) {
    final theme = Theme.of(context);

    return switch (label) {
      IconData icon => Icon(icon),
      String text => Text(
          text,
          style: isTitle
              ? theme.textTheme.titleMedium
              : theme.textTheme.bodyMedium
                  ?.copyWith(color: theme.appBarTheme.iconTheme?.color),
          textAlign: TextAlign.center,
        ),
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
              children: menu.asMap().entries.map((entry) {
                final isTitleItem = _isTitle(entry.key);
                return Expanded(
                  flex: isTitleItem ? 4 : 1,
                  child: _buildMenuContent(
                    context,
                    entry.value,
                    isTitle: isTitleItem,
                  ),
                );
              }).toList(),
            ),
    );
  }

  Widget _buildMenuContent(BuildContext context, AppBarMenuItem item,
      {required bool isTitle}) {
    if (item.label is SizedBox && (item.label as SizedBox).width == 24) {
      return GestureDetector(
        onTap: item.enabled ? () => item.action?.run(context) : null,
        child: Opacity(
          opacity: item.enabled ? 1.0 : 0.5,
          child: const SizedBox.shrink(),
        ),
      );
    }

    return GestureDetector(
      onTap: item.enabled ? () => item.action?.run(context) : null,
      child: Opacity(
        opacity: item.enabled ? 1.0 : 0.5,
        child: Container(
          height: kToolbarHeight,
          alignment: Alignment.center,
          child: item.buildLabel(context, isTitle: isTitle),
        ),
      ),
    );
  }

  bool _isTitle(int index) => index == menu.length ~/ 2;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
