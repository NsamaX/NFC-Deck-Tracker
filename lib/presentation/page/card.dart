import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:nfc_deck_tracker/.injector/setup_locator.dart';
import 'package:nfc_deck_tracker/domain/entity/card.dart';

import '@argument.dart';

import '../cubit/card_cubit.dart';
import '../cubit/deck_cubit.dart';
import '../cubit/nfc_cubit.dart';
import '../widget/app_bar/card.dart';
import '../widget/card/image.dart';
import '../widget/card/info.dart';
import '../widget/card/quantity_selector.dart';
import '../widget/card/custom_image.dart';
import '../widget/card/custom_info.dart';
import '../widget/wrapper/writer_listener.dart';

class CardPage extends StatefulWidget {
  const CardPage({super.key});

  @override
  State<CardPage> createState() => _CardPageState();
}

class _CardPageState extends State<CardPage> {
  late final CardCubit cardCubit;

  @override
  void initState() {
    super.initState();
    cardCubit = locator<CardCubit>();
  }

  @override
  void dispose() {
    cardCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<CardCubit>.value(
      value: cardCubit,
      child: const _CardContent(),
    );
  }
}

class _CardContent extends StatefulWidget {
  const _CardContent();

  @override
  State<_CardContent> createState() => _CardPageContent();
}

class _CardPageContent extends State<_CardContent> {
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
            appBar: CardAppBar(
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
                  CardCustomImage(cardCubit: cardCubit),
                  const SizedBox(height: 24.0),
                  CardCustomInfo(
                    cardCubit: cardCubit,
                    nameController: nameController,
                    descriptionController: descriptionController,
                    abilityController: abilityController,
                  ),
                ] else ...[
                  CardImage(card: card),
                  const SizedBox(height: 24.0),
                  CardInfo(card: card),
                ],
                if (onAdd)
                  BlocSelector<DeckCubit, DeckState, int>(
                    selector: (state) => state.selectedCardCount,
                    builder: (context, quantity) {
                      return CardQuantitySelector(
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
