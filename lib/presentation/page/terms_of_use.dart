import 'package:flutter/material.dart';

import '../locale/localization.dart';
import '../widget/shared/app_bar.dart';
import '../widget/shared/ui_constant.dart';

class TermsOfUsePage extends StatelessWidget {
  const TermsOfUsePage({super.key});

  @override
  Widget build(BuildContext context) {
    final locale = AppLocalization.of(context);

    return Scaffold(
      appBar: AppBarWidget(
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
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      ),
    );
  }
}
