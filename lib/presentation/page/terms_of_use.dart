import 'package:flutter/material.dart';

import '../locale/localization.dart';
import '../widget/app_bar/@default.dart';
import '../widget/constant/ui.dart';

class TermsOfUsePage extends StatelessWidget {
  const TermsOfUsePage({super.key});

  @override
  Widget build(BuildContext context) {
    final locale = AppLocalization.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: DefaultAppBar(
        menu: [
          AppBarMenuItem.back(),
          AppBarMenuItem(
            label: locale.translate('page_terms_of_use.app_bar'),
          ),
          AppBarMenuItem.empty(),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(UIConstant.paddingAround),
        child: SingleChildScrollView(
          child: Text(
            locale.translate('page_terms_of_use.content'),
            style: theme.textTheme.bodyMedium,
          ),
        ),
      ),
    );
  }
}
