import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../shared/image_constant.dart';
import '../shared/ui_constant.dart';

import '../../cubit/application_cubit.dart';
import '../../cubit/drawer_cubit.dart';
import '../../locale/localization.dart';
import '../../route/route.dart';

class CollectionDrawerWidget extends StatelessWidget {
  const CollectionDrawerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final locale = AppLocalization.of(context);

    return BlocSelector<DrawerCubit, DrawerState, bool>(
      selector: (state) => state.visibleFeatureDrawer,
      builder: (_, isOpen) => AnimatedPositioned(
        duration: UIConstant.drawerTransitionDuration,
        curve: Curves.easeInOut,
        right: isOpen ? 0 : -80,
        top: 20,
        child: Padding(
          padding: const EdgeInsets.only(right: 8),
          child: BlocBuilder<ApplicationCubit, ApplicationState>(
            builder: (_, state) => Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (state.recentId.isNotEmpty)
                  _buildItem(
                    context: context,
                    onTap: () => _navigate(
                      context: context,
                      route: RouteConstant.browse_card,
                      arguments: {
                        'collectionId': state.recentId,
                        'collectionName': state.recentGame,
                      },
                    ),
                    image: ImageConstant.games[state.recentId],
                  ),
                _buildItem(
                  context: context,
                  onTap: () => _navigate(
                    context: context,
                    route: RouteConstant.collection,
                  ),
                  text: locale.translate('page_collection.app_bar'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _navigate({
    required BuildContext context,
    required String route,
    Map<String, dynamic>? arguments,
  }) {
    Navigator.of(context).pushNamed(route, arguments: arguments);
  }

  Widget _buildItem({
    required BuildContext context,
    VoidCallback? onTap,
    String? image,
    String? text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            boxShadow: const [
              BoxShadow(
                color: Color.fromRGBO(0, 0, 0, 0.2),
                blurRadius: 4,
                spreadRadius: 1,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: _buildContent(context, image: image, text: text),
        ),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context, {
    String? image,
    String? text,
  }) {
    final theme = Theme.of(context);

    if (image != null) {
      return image.isEmpty
          ? const Icon(Icons.inbox_rounded, color: Colors.black, size: 36)
          : ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                image,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) =>
                    const Icon(Icons.broken_image),
              ),
            );
    }

    if (text != null && text.isNotEmpty) {
      return Center(
        child: Text(
          text,
          style: theme.textTheme.bodySmall?.copyWith(color: Colors.black),
          textAlign: TextAlign.center,
        ),
      );
    }

    return const Icon(Icons.inbox_rounded, color: Colors.black, size: 36);
  }
}
