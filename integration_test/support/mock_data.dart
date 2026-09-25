import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

import 'package:nfc_deck_tracker/.injector/service_locator.dart';
import 'package:nfc_deck_tracker/domain/entity/card.dart';
import 'package:nfc_deck_tracker/domain/entity/card_in_deck.dart';
import 'package:nfc_deck_tracker/domain/entity/data.dart';
import 'package:nfc_deck_tracker/domain/entity/deck.dart';
import 'package:nfc_deck_tracker/domain/entity/record.dart';
import 'package:nfc_deck_tracker/domain/usecase/index.dart';
import 'package:nfc_deck_tracker/domain/value/player_action.dart';

class MockCard {
  final String name;
  final String description;
  final String ability;
  final Color color;

  const MockCard(this.name, this.description, this.ability, this.color);
}

const aetherCards = [
  MockCard('Ember Drake', 'Dragon - Power 5 / Guard 4',
      'When it enters, deal 2 damage to each rival unit.', Color(0xFFD9542C)),
  MockCard('Tide Serpent', 'Serpent - Power 4 / Guard 5',
      'Return one unit to its owner\'s hand.', Color(0xFF2C7FD9)),
  MockCard('Grove Warden', 'Treefolk - Power 2 / Guard 7',
      'Other allies get +0 / +1.', Color(0xFF3F9A4B)),
  MockCard('Storm Caller', 'Mage - Power 3 / Guard 2',
      'Draw a card whenever you cast a spell.', Color(0xFF7A55C8)),
  MockCard('Iron Golem', 'Construct - Power 6 / Guard 6',
      'Cannot block units with flying.', Color(0xFF7D8590)),
  MockCard('Shadow Wisp', 'Spirit - Power 1 / Guard 1', 'Cannot be blocked.',
      Color(0xFF3B3552)),
  MockCard('Sun Priestess', 'Cleric - Power 2 / Guard 3',
      'At the end of your turn, restore 2 life.', Color(0xFFE0B23A)),
  MockCard('Frost Giant', 'Giant - Power 7 / Guard 5',
      'Units dealt damage by it are frozen.', Color(0xFF6FC3D8)),
];

const starterCards = [
  MockCard('Village Guard', 'Soldier - Power 1 / Guard 3', 'Taunt.',
      Color(0xFF9C6B3D)),
  MockCard('Wandering Bard', 'Bard - Power 1 / Guard 1',
      'Allies get +1 power this turn.', Color(0xFFC24F8C)),
  MockCard('Stone Wall', 'Structure - Power 0 / Guard 8', 'Cannot attack.',
      Color(0xFF8A8A7A)),
];

class MockWorld {
  final String aetherId;
  final String starterId;
  final Map<String, CardEntity> cards;
  final DeckEntity fireDeck;
  final DeckEntity tideDeck;

  MockWorld({
    required this.aetherId,
    required this.starterId,
    required this.cards,
    required this.fireDeck,
    required this.tideDeck,
  });
}

Future<String> _artwork(MockCard card, Directory dir) async {
  const width = 480.0, height = 670.0;
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);
  final rect = const Rect.fromLTWH(0, 0, width, height);
  canvas.drawRect(
      rect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [card.color, Color.lerp(card.color, Colors.black, 0.55)!],
        ).createShader(rect));
  canvas.drawCircle(const Offset(width / 2, height * 0.42), 130,
      Paint()..color = Colors.white.withValues(alpha: 0.18));
  final initials = card.name.split(' ').map((w) => w[0]).join();
  final painter = TextPainter(
    text: TextSpan(
      text: initials,
      style: const TextStyle(
          fontSize: 140, fontWeight: FontWeight.w700, color: Colors.white),
    ),
    textDirection: TextDirection.ltr,
  )..layout();
  painter.paint(canvas,
      Offset((width - painter.width) / 2, height * 0.42 - painter.height / 2));
  final title = TextPainter(
    text: TextSpan(
      text: card.name,
      style: const TextStyle(fontSize: 38, color: Colors.white),
    ),
    textDirection: TextDirection.ltr,
  )..layout(maxWidth: width - 40);
  title.paint(canvas, Offset((width - title.width) / 2, height - 110));

  final image =
      await recorder.endRecording().toImage(width.toInt(), height.toInt());
  final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
  final file = File('${dir.path}/mock_${initials.toLowerCase()}.png');
  await file.writeAsBytes(bytes!.buffer.asUint8List());
  return file.path;
}

DataEntity _log(CardEntity card, int tag, PlayerAction action, DateTime at) =>
    DataEntity(
      tagId: 'tag-${card.cardId.substring(0, 4)}-$tag',
      collectionId: card.collectionId,
      cardId: card.cardId,
      location: action == PlayerAction.take ? 'deck' : 'hand',
      playerAction: action,
      timestamp: at,
    );

/// Wipes guest data and seeds collections, cards with generated artwork,
/// two decks, and two game records through the app's own use cases.
Future<MockWorld> seedMockData() async {
  await locator<ClearUserDataUsecase>()(isGuest: true);

  final dir = await getApplicationDocumentsDirectory();
  final createCollection = locator<CreateCollectionUsecase>();
  final createCard = locator<CreateCardUsecase>();

  final starter = await createCollection(userId: '', name: 'Starter Set');
  final aether = await createCollection(userId: '', name: 'Aether Chronicles');

  final cards = <String, CardEntity>{};
  for (final (collectionId, list) in [
    (starter.collectionId, starterCards),
    (aether.collectionId, aetherCards),
  ]) {
    for (final mock in list) {
      cards[mock.name] = await createCard(
        userId: '',
        card: CardEntity(
          collectionId: collectionId,
          name: mock.name,
          description: mock.description,
          imageUrl: await _artwork(mock, dir),
          additionalData: {'>': mock.ability},
        ),
      );
    }
  }

  CardInDeckEntity entry(String name, int count) =>
      CardInDeckEntity(card: cards[name]!, count: count);
  final createDeck = locator<CreateDeckUsecase>();
  final tideDeck = await createDeck(
    userId: '',
    deck: DeckEntity(name: 'Tidal Control', cards: [
      entry('Tide Serpent', 3),
      entry('Frost Giant', 2),
      entry('Shadow Wisp', 2),
      entry('Grove Warden', 2),
    ]),
  );
  final fireDeck = await createDeck(
    userId: '',
    deck: DeckEntity(name: 'Fire Rush', cards: [
      entry('Ember Drake', 3),
      entry('Storm Caller', 2),
      entry('Iron Golem', 2),
      entry('Sun Priestess', 1),
    ]),
  );

  final createRecord = locator<CreateRecordUsecase>();
  final day1 = DateTime(2026, 9, 20, 19, 5);
  final ember = cards['Ember Drake']!;
  final storm = cards['Storm Caller']!;
  final golem = cards['Iron Golem']!;
  final priest = cards['Sun Priestess']!;
  await createRecord(
    userId: '',
    record: RecordEntity(
      deckId: fireDeck.deckId,
      recordId: '',
      createdAt: day1,
      data: [
        _log(ember, 1, PlayerAction.take, day1),
        _log(storm, 1, PlayerAction.take, day1.add(const Duration(minutes: 2))),
        _log(ember, 2, PlayerAction.take, day1.add(const Duration(minutes: 4))),
        _log(ember, 1, PlayerAction.give, day1.add(const Duration(minutes: 6))),
        _log(golem, 1, PlayerAction.take, day1.add(const Duration(minutes: 9))),
      ],
    ),
  );
  final day2 = DateTime(2026, 9, 22, 20, 30);
  await createRecord(
    userId: '',
    record: RecordEntity(
      deckId: fireDeck.deckId,
      recordId: '',
      createdAt: day2,
      data: [
        _log(priest, 1, PlayerAction.take, day2),
        _log(ember, 1, PlayerAction.take, day2.add(const Duration(minutes: 1))),
        _log(storm, 1, PlayerAction.take, day2.add(const Duration(minutes: 3))),
        _log(storm, 2, PlayerAction.take, day2.add(const Duration(minutes: 5))),
        _log(golem, 1, PlayerAction.take, day2.add(const Duration(minutes: 7))),
        _log(golem, 2, PlayerAction.take, day2.add(const Duration(minutes: 8))),
      ],
    ),
  );

  return MockWorld(
    aetherId: aether.collectionId,
    starterId: starter.collectionId,
    cards: cards,
    fireDeck: fireDeck,
    tideDeck: tideDeck,
  );
}
