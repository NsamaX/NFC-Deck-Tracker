import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../cubit/application_cubit.dart';
import '../../locale/localization.dart';

class BottomNavigationBarWidget extends StatelessWidget implements PreferredSizeWidget {
  const BottomNavigationBarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final locale = AppLocalization.of(context);
    final applicationCubit = context.read<ApplicationCubit>();

    return BlocBuilder<ApplicationCubit, ApplicationState>(
      builder: (_, state) => BottomNavigationBar(
        currentIndex: state.currentPageIndex,
        items: _navItems.map((item) => _buildItem(locale, item)).toList(),
        onTap: (index) {
          if (index != state.currentPageIndex) {
            applicationCubit.setPageIndex(index: index);
            Navigator.of(context).pushNamedAndRemoveUntil(
              applicationCubit.getPageRoute(index: index),
              (_) => false,
            );
          }
        },
      ),
    );
  }

  BottomNavigationBarItem _buildItem(AppLocalization locale, _NavItem item) {
    return BottomNavigationBarItem(
      icon: Icon(item.icon),
      label: locale.translate(item.labelKey),
    );
  }

  static const List<_NavItem> _navItems = [
    _NavItem(Icons.web_stories_rounded, 'bottom_navigation_bar.deck_list'),
    _NavItem(Icons.nfc_rounded, 'bottom_navigation_bar.card_reader'),
    _NavItem(Icons.settings_outlined, 'bottom_navigation_bar.setting'),
  ];

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _NavItem {
  final IconData icon;
  final String labelKey;

  const _NavItem(this.icon, this.labelKey);
}
