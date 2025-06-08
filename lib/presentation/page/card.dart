import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:nfc_deck_tracker/.injector/setup_locator.dart';

import 'package:nfc_deck_tracker/domain/entity/card.dart';

import '_argument.dart';

import '../cubit/card_cubit.dart';
import '../cubit/deck_cubit.dart';
import '../cubit/nfc_cubit.dart';
import '../widget/specific/app_bar/card_page.dart';
import '../widget/specific/card_image.dart';
import '../widget/specific/card_info.dart';
import '../widget/specific/card_quantity_selector.dart';
import '../widget/specific/custom_card_image.dart';
import '../widget/specific/custom_card_info.dart';
import '../widget/specific/writer_listener.dart';

class CardPage extends StatelessWidget {
  const CardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: locator<CardCubit>(),
      child: const _CardPageContent(),
    );
  }
}

class _CardPageContent extends StatefulWidget {
  const _CardPageContent();

  @override
  State<_CardPageContent> createState() => _CardPageContentState();
}

class _CardPageContentState extends State<_CardPageContent> {
  late final TextEditingController nameController;
  late final TextEditingController descriptionController;
  late final TextEditingController abilityController;
  late NfcCubit nfcCubit;

  @override
  void initState() {
    super.initState();

    nameController = TextEditingController();
    descriptionController = TextEditingController();
    abilityController = TextEditingController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    nfcCubit = context.read<NfcCubit>();
  }

  @override
  void dispose() {
    nameController.dispose();
    descriptionController.dispose();
    abilityController.dispose();

    if (nfcCubit.state.isSessionActive) {
      nfcCubit.stopSession();
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final args = getArguments(context);
    final card = args['card'] as CardEntity? ?? CardEntity();
    final onCustom = args['onCustom'] ?? false;
    final onNFC = args['onNFC'] ?? false;
    final onAdd = args['onAdd'] ?? false;
    final userId = FirebaseAuth.instance.currentUser?.uid ?? '';
    final cardCubit = context.read<CardCubit>();

    return WriterListener(
      child: BlocBuilder<NfcCubit, NfcState>(
        builder: (context, state) {
          return Scaffold(
            appBar: AppBarCardAppPage(
              userId: userId,
              card: card,
              onNFC: onNFC,
              onAdd: onAdd,
              onCustom: onCustom,
            ),
            body: ListView(
              padding: const EdgeInsets.all(40.0),
              children: [
                if (onCustom) ...[
                  CustomCardImageWidget(cardCubit: cardCubit),
                  const SizedBox(height: 24.0),
                  CustomCardInfoWidget(
                    cardCubit: cardCubit,
                    nameController: nameController,
                    descriptionController: descriptionController,
                    abilityController: abilityController,
                  ),
                ] else ...[
                  CardImageWidget(card: card),
                  const SizedBox(height: 24.0),
                  CardInfoWidget(card: card),
                ],
                if (onAdd)
                  BlocSelector<DeckCubit, DeckState, int>(
                    selector: (state) => state.selectedCardCount,
                    builder: (context, quantity) {
                      return CardQuantitySelectorWidget(
                        onSelected: (q) {
                          context.read<DeckCubit>().setCardQuantity(quantity: q);
                        },
                        quantityCount: 4,
                        selectedQuantity: quantity,
                      );
                    },
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
