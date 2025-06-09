import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../cubit/drawer_cubit.dart';
import '../../locale/localization.dart';

import '../qr_code/generetor.dart';
import '../qr_code/scanner.dart';

class CreateRoomDrawer extends StatelessWidget {
  final String userId;

  const CreateRoomDrawer({
    super.key,
    required this.userId,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DrawerCubit, DrawerState>(
      buildWhen: (previous, current) => previous.visibleFeatureDrawer != current.visibleFeatureDrawer,
      builder: (context, state) {
        return AnimatedPositioned(
          duration: const Duration(milliseconds: 160),
          top: state.visibleFeatureDrawer ? 0.0 : -160.0,
          left: 0,
          child: SizedBox(
            width: 160,
            height: 90,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                _DrawerContainer(userId: userId),
                const Positioned(
                  bottom: -20,
                  left: 0,
                  right: 0,
                  child: CustomPaint(
                    painter: DoubleTrianglePainter(color: Colors.white),
                    size: Size(200, 20),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _DrawerContainer extends StatelessWidget {
  final String userId;

  const _DrawerContainer({required this.userId});

  @override
  Widget build(BuildContext context) {
    final locale = AppLocalization.of(context);

    return Container(
      width: 200,
      height: 150,
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.2),
            offset: Offset(0, 4),
            blurRadius: 4,
            spreadRadius: 2,
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _DrawerItem(
            icon: Icons.qr_code_rounded,
            text: locale.translate('page_deck_tracker.toggle_create_room'),
            onTap: () => _showQRCodeCreatedRoom(context),
          ),
          const SizedBox(height: 8),
          const Divider(height: 1, color: Color(0xFFE0E0E0)),
          const SizedBox(height: 8),
          _DrawerItem(
            icon: Icons.qr_code_scanner_rounded,
            text: locale.translate('page_deck_tracker.toggle_join_room'),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const QRCodeScanner(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  void _showQRCodeCreatedRoom(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.zero,
        child: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () => Navigator.of(context).pop(),
          child: Center(
            child: GestureDetector(
              onTap: () {},
              child: QRCodeGeneretor(userId: userId),
            ),
          ),
        ),
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String text;
  final VoidCallback? onTap;

  const _DrawerItem({
    required this.icon,
    required this.text,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      child: Row(
        children: [
          const SizedBox(width: 16),
          Icon(icon, color: Colors.black, size: 24),
          const SizedBox(width: 8),
          Text(
            text,
            style: theme.textTheme.titleSmall?.copyWith(color: Colors.black),
          ),
        ],
      ),
    );
  }
}

class DoubleTrianglePainter extends CustomPainter {
  final Color color;

  const DoubleTrianglePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;

    final left = Path()
      ..moveTo(0, 0)
      ..lineTo(0, size.height)
      ..lineTo(size.width / 2, 0)
      ..close();

    final right = Path()
      ..moveTo(size.width, 0)
      ..lineTo(size.width, size.height)
      ..lineTo(size.width / 2, 0)
      ..close();

    canvas.drawPath(left, paint);
    canvas.drawPath(right, paint);
  }

  @override
  bool shouldRepaint(covariant DoubleTrianglePainter oldDelegate) =>
      color != oldDelegate.color;
}
