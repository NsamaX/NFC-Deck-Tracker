import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:nfc_deck_tracker/.config/app.dart';

import 'package:nfc_deck_tracker/data/datasource/api/@api_config.dart';

import '../../cubit/application_cubit.dart';
import '../../route/route_constant.dart';

class SupportedGameTile extends StatelessWidget {
  final String gameKey;
  final String gameImage;
  final bool onAdd;

  const SupportedGameTile({
    super.key,
    required this.gameKey,
    required this.gameImage,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final description = ApiConfig.getBaseUrl(key: gameKey);

    return GestureDetector(
      onTap: () => _goToSearchPage(context),
      child: Container(
        margin: const EdgeInsets.only(bottom: 6.0),
        height: 60.0,
        decoration: BoxDecoration(
          color: theme.appBarTheme.backgroundColor,
          borderRadius: BorderRadius.circular(12.0),
          boxShadow: const [
            BoxShadow(
              color: Color.fromRGBO(0, 0, 0, 0.2),
              spreadRadius: 1.0,
              blurRadius: 2.0,
              offset: Offset(0, 3),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12.0),
        child: Row(
          children: [
            _buildImageBox(),
            const SizedBox(width: 12.0),
            _buildInfoText(context, description),
          ],
        ),
      ),
    );
  }

  void _goToSearchPage(BuildContext context) {
    final applicationCubit = context.read<ApplicationCubit>();
    applicationCubit.updateSetting(
      key: App.keyRecentId,
      value: gameKey,
    );
    applicationCubit.updateSetting(
      key: App.keyRecentGame,
      value: gameKey,
    );
    Navigator.of(context).pushReplacementNamed(
      RouteConstant.browse_card,
      arguments: {
        'collectionId': gameKey,
        'collectionName': gameKey,
        'onAdd': onAdd,
      },
    );
  }

  Widget _buildImageBox() {
    return Container(
      width: 36,
      height: 36,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(8)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.asset(
          gameImage,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => const Icon(Icons.inbox_rounded, color: Colors.black, size: 24),
        ),
      ),
    );
  }

  Widget _buildInfoText(BuildContext context, String description) {
    final theme = Theme.of(context);

    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            gameKey,
            style: theme.textTheme.bodyMedium,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
          const SizedBox(height: 4),
          Text(
            description.cleanSlashComment(),
            style: theme.textTheme.bodySmall,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ],
      ),
    );
  }
}

extension on String {
  String cleanSlashComment() => contains('//') ? split('//')[1] : this;
}
