import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../cubit/application_cubit.dart';
import '../../locale/localization.dart';

class _NavItem {
  final String labelKey;
  final IconData icon;

  const _NavItem(
    this.labelKey,
    this.icon, 
  );
}

class BottomNavigationBarWidget extends StatelessWidget implements PreferredSizeWidget {
  const BottomNavigationBarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ApplicationCubit, ApplicationState>(
      builder: (_, state) => BottomNavigationBar(
        currentIndex: state.currentPageIndex,
        items: _navItems.map((item) => _buildItem(context, item: item)).toList(),
        onTap: (index) {
          if (index != state.currentPageIndex) {
            context.read<ApplicationCubit>().setPageIndex(index: index);
            Navigator.of(context).pushNamedAndRemoveUntil(
              context.read<ApplicationCubit>().getPageRoute(index: index),
              (_) => false,
            );
          }
        },
      ),
    );
  }

  BottomNavigationBarItem _buildItem(
    BuildContext context, {
    required _NavItem item,
  }) {
    return BottomNavigationBarItem(
      icon: Icon(item.icon),
      label: AppLocalization.of(context).translate(item.labelKey),
    );
  }

  static const List<_NavItem> _navItems = [
    _NavItem('bottom_navigation_bar.deck_list', Icons.web_stories_rounded),
    _NavItem('bottom_navigation_bar.card_reader', Icons.nfc_rounded),
    _NavItem('bottom_navigation_bar.setting', Icons.settings_outlined),
  ];

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
