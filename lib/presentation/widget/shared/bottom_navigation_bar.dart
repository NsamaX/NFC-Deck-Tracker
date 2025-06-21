import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../cubit/application.dart';
import '../../locale/localization.dart';

import '../constant/icon.dart';

class _NavItem {
  final String labelKey;
  final String iconPath;

  const _NavItem(
    this.labelKey,
    this.iconPath, 
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
    final theme = Theme.of(context).bottomNavigationBarTheme;

    return BottomNavigationBarItem(
      icon: SvgPicture.asset(
        item.iconPath,
        width: 24,
        height: 24,
        colorFilter: ColorFilter.mode(
          theme.unselectedItemColor ?? Colors.grey,
          BlendMode.srcIn,
        ),
      ),
      activeIcon: SvgPicture.asset(
        item.iconPath,
        width: 24,
        height: 24,
        colorFilter: ColorFilter.mode(
          theme.selectedItemColor ?? Colors.blue,
          BlendMode.srcIn,
        ),
      ),
      label: AppLocalization.of(context).translate(item.labelKey),
    );
  }

  static List<_NavItem> _navItems = [
    _NavItem('bottom_navigation_bar.deck_list', IconConstant.decks),
    _NavItem('bottom_navigation_bar.card_reader', IconConstant.nfcSearch),
    _NavItem('bottom_navigation_bar.setting', IconConstant.setting),
  ];

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
