import 'package:flutter/material.dart';
import '../dependencies.dart';

import '../locale/localization.dart';
import '../widget/app_bar/@default.dart';
import '../widget/text/description_align_center.dart';
import '../constant.dart';

class AboutPage extends StatefulWidget {
  const AboutPage({super.key});

  @override
  State<AboutPage> createState() => _AboutPage();
}

class _AboutPage extends State<AboutPage> {
  late final Future<String> packageInfoFuture;

  @override
  void initState() {
    super.initState();

    packageInfoFuture = PresentationScope.read(context).device.appVersion();
  }

  @override
  Widget build(BuildContext context) {
    final locale = AppLocalization.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: DefaultAppBar(
        menu: [
          AppBarMenuItem.back(),
          AppBarMenuItem(
            label: locale.translate('page_about.app_bar'),
          ),
          AppBarMenuItem.empty(),
        ],
      ),
      body: FutureBuilder<String>(
        future: packageInfoFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError || !snapshot.hasData) {
            return DescriptionAlignCenter(
              text: locale.translate('common.error_loading'),
              bottomNavHeight: true,
            );
          }

          final version = snapshot.data!;
          final content = locale
              .translate('page_about.content')
              .replaceFirst('{version}', version);

          return Padding(
            padding: const EdgeInsets.all(WidgetConstant.paddingAround),
            child: SingleChildScrollView(
              child: Text(
                content,
                style: theme.textTheme.bodyMedium,
              ),
            ),
          );
        },
      ),
    );
  }
}
