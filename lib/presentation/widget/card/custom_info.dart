import 'package:flutter/material.dart';

import '../../cubit/card_cubit.dart';
import '../../locale/localization.dart';
import '../../theme/@theme.dart';

class CardCustomInfo extends StatelessWidget {
  final CardCubit cardCubit;
  final String collectionId;
  final TextEditingController nameController;
  final TextEditingController descriptionController;
  final TextEditingController abilityController;

  const CardCustomInfo({
    super.key,
    required this.cardCubit,
    required this.collectionId,
    required this.nameController,
    required this.descriptionController,
    required this.abilityController,
  });

  @override
  Widget build(BuildContext context) {
    final locale = AppLocalization.of(context);

    return Column(
      children: [
        _buildField(
          context,
          controller: nameController,
          hintText: locale.translate('card.name'),
          onChanged: (text) => cardCubit.setCardName(name: text),
          showAsterisk: true,
        ),
        const SizedBox(height: 16.0),
        _buildField(
          context,
          controller: descriptionController,
          hintText: locale.translate('card.description'),
          onChanged: (text) => cardCubit.setCardDescription(description: text),
        ),
        const SizedBox(height: 26.0),
        _buildField(
          context,
          controller: abilityController,
          hintText: locale.translate('card.ability'),
          onChanged: (text) => cardCubit.setCardAdditionalData(additionalData: {'>': text}),
          isTextArea: true,
        ),
      ],
    );
  }

  Widget _buildField(
    BuildContext context, {
    required TextEditingController controller,
    required String hintText,
    required void Function(String) onChanged,
    bool isTextArea = false,
    bool showAsterisk = false,
  }) {
    final theme = Theme.of(context);

    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: controller,
      builder: (context, value, _) {
        final hasText = value.text.isNotEmpty;
        final hintStyle = TextStyle(
          color: theme.textTheme.bodySmall!.color!.withAlpha((hasText ? 255 : (0.2 * 255)).toInt()),
        );

        final textField = TextField(
          controller: controller,
          maxLines: null,
          textAlign: TextAlign.start,
          style: theme.textTheme.bodySmall,
          decoration: InputDecoration(
            border: InputBorder.none,
            hintText: hintText,
            hintStyle: hintStyle,
            isDense: true,
          ),
          onChanged: onChanged,
        );

        if (isTextArea) {
          return Container(
            height: 120.0,
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
            decoration: BoxDecoration(
              border: Border.all(
                color: theme.textTheme.bodySmall!.color!.withAlpha((hasText ? 255 : (0.2 * 255)).toInt()),
                width: 1.0,
              ),
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: textField,
          );
        }

        return Column(
          children: [
            Row(
              children: [
                const SizedBox(width: 12.0),
                Expanded(child: textField),
                if (showAsterisk)
                  Opacity(
                    opacity: hasText ? 0.2 : 1.0,
                    child: const Padding(
                      padding: EdgeInsets.only(top: 4.0),
                      child: Text("*", style: TextStyle(fontSize: 18, color: Colors.white)),
                    ),
                  ),
                if (showAsterisk) const SizedBox(width: 4.0),
              ],
            ),
            const SizedBox(height: 4.0),
            Opacity(
              opacity: 0.2,
              child: Container(
                width: double.infinity,
                height: 1,
                color: theme.colorScheme.opacity_text,
              ),
            ),
          ],
        );
      },
    );
  }
}
