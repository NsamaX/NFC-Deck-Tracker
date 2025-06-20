import 'package:flutter/material.dart';

import '../locale/localization.dart';
import '../widget/app_bar/@default.dart';
import '../widget/constant/ui.dart';

class PrivacyPage extends StatelessWidget {
  const PrivacyPage({super.key});

  @override
  Widget build(BuildContext context) {
    final locale = AppLocalization.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: DefaultAppBar(
        menu: [
          AppBarMenuItem.back(),
          AppBarMenuItem(
            label: locale.translate('page_privacy.app_bar'),
          ),
          AppBarMenuItem.empty(),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(UIConstant.paddingAround),
        child: SingleChildScrollView(
          child: Text(
            locale.translate('page_privacy.content'),
            style: theme.textTheme.bodyMedium,
          ),
        ),
      ),
    );
  }
}
