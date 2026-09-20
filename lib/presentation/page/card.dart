import 'package:nfc_deck_tracker/presentation/dependencies.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/card/bloc.dart';
import '../bloc/deck/bloc.dart';
import '../bloc/nfc/bloc.dart';
import '../widget/app_bar/card.dart';
import '../widget/card/custom_image.dart';
import '../widget/card/custom_info.dart';
import '../widget/card/image.dart';
import '../widget/card/info.dart';
import '../widget/card/quantity_selector.dart';
import '../widget/listener/writer.dart';
import '../route/arguments.dart';

class CardPage extends StatefulWidget {
  const CardPage({super.key});

  @override
  State<CardPage> createState() => _CardPageState();
}

class _CardPageState extends State<CardPage> {
  late final CardBloc cardBloc;

  @override
  void initState() {
    super.initState();
    cardBloc = PresentationScope.read(context).createCardBloc();
  }

  @override
  void dispose() {
    cardBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<CardBloc>.value(
      value: cardBloc,
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
  late NfcBloc nfcBloc;

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
    nfcBloc = context.read<NfcBloc>();
  }

  @override
  void dispose() {
    nameController.dispose();
    descriptionController.dispose();
    abilityController.dispose();

    if (nfcBloc.state.isSessionActive) {
      nfcBloc.add(StopNfcSessionEvent());
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final CardArgs(:card, :collectionId, :onCustom, :onAdd) =
        CardArgs.of(context);

    return WriterListener(
      child: BlocBuilder<NfcBloc, NfcState>(
        builder: (context, state) {
          return Scaffold(
            appBar: const CardAppBar(),
            body: ListView(
              padding: const EdgeInsets.all(40.0),
              children: [
                if (onCustom) ...[
                  CardCustomImage(),
                  const SizedBox(height: 24.0),
                  CardCustomInfo(
                    collectionId: collectionId,
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
                  BlocSelector<DeckBloc, DeckState, int>(
                    selector: (state) => state.cardQuantity,
                    builder: (context, quantity) {
                      return CardQuantitySelector(
                        onSelected: (q) {
                          context
                              .read<DeckBloc>()
                              .add(SetCardQuantityEvent(quantity: q));
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
