import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../cubit/drawer_cubit.dart';
import '../../locale/localization.dart';

class CreateRoomDrawerWidget extends StatelessWidget {
  const CreateRoomDrawerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DrawerCubit, DrawerState>(
      buildWhen: (previous, current) => previous.visibleFeatureDrawer != current.visibleFeatureDrawer,
      builder: (context, state) => AnimatedPositioned(
        duration: const Duration(milliseconds: 160),
        top: state.visibleFeatureDrawer ? 0.0 : -160.0,
        left: 0,
        child: SizedBox(
          width: 160,
          height: 90,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              _buildDrawerContainer(context),
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
      ),
    );
  }

  Widget _buildDrawerContainer(BuildContext context) {
    final locale = AppLocalization.of(context);
    final theme = Theme.of(context);

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
          _buildLabelText(theme, icon: Icons.qr_code_rounded, text: locale.translate('page_deck_tracker.toggle_create_room')),
          const SizedBox(height: 8),
          const Divider(height: 1, color: Color(0xFFE0E0E0)),
          const SizedBox(height: 8),
          _buildLabelText(theme, icon: Icons.qr_code_scanner_rounded, text: locale.translate('page_deck_tracker.toggle_join_room')),
        ],
      ),
    );
  }

  Widget _buildLabelText(ThemeData theme, {
    required IconData icon,
    required String text,
  }) {
    return Row(
      children: [
        const SizedBox(width: 16),
        Icon(icon, color: Colors.black, size: 24),
        const SizedBox(width: 8),
        Text(
          text,
          style: theme.textTheme.titleSmall?.copyWith(color: Colors.black),
        ),
      ],
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
