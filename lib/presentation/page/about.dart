import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../locale/localization.dart';
import '../widget/shared/app_bar.dart';
import '../widget/shared/description_align_center.dart';
import '../widget/shared/ui_constant.dart';

class AboutPage extends StatefulWidget {
  const AboutPage({super.key});

  @override
  State<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  late final Future<PackageInfo> packageInfoFuture;

  @override
  void initState() {
    super.initState();

    packageInfoFuture = PackageInfo.fromPlatform();
  }

  @override
  Widget build(BuildContext context) {
    final locale = AppLocalization.of(context);

    return Scaffold(
      appBar: AppBarWidget(
        menu: [
          AppBarMenuItem.back(),
          AppBarMenuItem(
            label: locale.translate('page_about.app_bar'),
          ),
          AppBarMenuItem.empty(),
        ],
      ),
      body: FutureBuilder<PackageInfo>(
        future: packageInfoFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError || !snapshot.hasData || snapshot.data == null) {
            return DescriptionAlignCenter(
              text: locale.translate('common.error_loading'),
              bottomNavHeight: true,
            );
          }

          final version = snapshot.data!.version;
          final content = locale
              .translate('page_about.content')
              .replaceFirst('{version}', version);

          return Padding(
            padding: const EdgeInsets.all(UIConstant.paddingAround),
            child: SingleChildScrollView(
              child: Text(
                content,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          );
        },
      ),
    );
  }
}
