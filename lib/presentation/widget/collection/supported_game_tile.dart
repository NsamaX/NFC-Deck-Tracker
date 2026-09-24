import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:nfc_deck_tracker/.config/api.dart';
import '../../bloc/application/bloc.dart';
import '../../constant.dart';
import '../../route/constant.dart';
import '../../route/arguments.dart';

class SupportedGameTile extends StatelessWidget {
  final String gameKey;
  final String gameImage;

  const SupportedGameTile({
    super.key,
    required this.gameKey,
    required this.gameImage,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final description = ApiConfig.instance.getBaseUrl(gameKey);

    return GestureDetector(
      onTap: () => _goToSearchPage(context),
      child: Container(
        margin: WidgetConstant.tileSpacing,
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
    final applicationBloc = context.read<ApplicationBloc>();
    applicationBloc.add(UpdateSettingsEvent(
        (s) => s.copyWith(recentId: gameKey, recentGame: gameKey)));
    Navigator.of(context).pushReplacementNamed(
      RouteConstant.browse_card,
      arguments: BrowseCardArgs(
        collectionId: gameKey,
        collectionName: gameKey,
        onAdd: CollectionArgs.of(context).onAdd,
      ),
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
        child: SvgPicture.asset(
          gameImage,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) =>
              const Icon(Icons.inbox_rounded, color: Colors.black, size: 24),
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
