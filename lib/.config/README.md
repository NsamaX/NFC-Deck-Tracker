<h1 align="center">🃏 How to Add a New Game</h1>

## Overview

This guide explains how to integrate a **new Trading Card Game (TCG)** into the NFC Deck Tracker app.  
Each game must be registered in the application along with its associated **API provider** and **paging strategy** to support card searching, deck tracking, and real-time updates via NFC.

---

## 📌 Prerequisites

- The game must have a publicly accessible card API (REST preferred)
- Card data must include at minimum: `cardId`, `name`, `imageUrl`, and optional metadata

---

## ✅ Step-by-Step Instructions

---

### 🔹 Step 1: Register Game in `GameConfig`

Files:
- `lib/.config/game.dart`

Add a new constant for your game ID and define API URLs under each environment (`development`, `production`).

```dart
class ApiConfig {
  static const dummy = 'dummy';
  static const pokemon = 'pokemon'; // https://dev.pokemontcg.io/dashboard
  static const newgame = 'newgame'; // <-- Add this

  static const Map<String, Map<String, String>> _baseUrls = {
    'development': {
      dummy: '',
      pokemon: 'https://api.pokemontcg.io/v2/',
      newgame: '', // <-- Add this
    },
    'production': {
      dummy: '',
      newgame: '', // <-- Add this if ready for production
    },
  };
}
```

---

### 🔹 Step 2: Create Game API and Paging Strategy

Folder: `lib/data/datasource/api/`

Create a new file named `{your_game}.dart` (e.g., `newgame.dart`) with:

  * A class implementing `GameApi`:

      * `fetch(...)`
      * `find(...)`

  * A class implementing `PagingStrategy`:

      * `buildPage(...)`

```dart
import 'package:nfc_deck_tracker/.config/game.dart';

import '../../model/card.dart';

import '@service_factory.dart';
import '&base_api.dart';

class NewGameApi extends BaseApi implements GameApi {
  NewGameApi({
    required String baseUrl,
  }) : super(baseUrl: baseUrl);

  @override
  Future<List<CardModel>> fetch({
    required Map<String, dynamic> page,
  }) async {
    final Map<String, String> queryParams = page.map(
      (k, v) => MapEntry(k, v.toString()),
    );

    final response = await getRequest(
      path: 'cards',
      queryParams: queryParams,
    );
    final body = decodeResponse(response: response);
    final List<dynamic> data = body['data'] ?? [];

    return _filterAndParseData(data: data);
  }

  @override
  Future<CardModel?> find({
    required String cardId,
  }) async {
    try {
      final response = await getRequest(path: 'cards/$cardId');
      final body = decodeResponse(response: response);

      if (body['data'] == null) return null;

      final data = body['data'] as Map<String, dynamic>;
      return _parseData(data: data);
    } catch (e) {
      // Log the error if necessary
      return null;
    }
  }

  // Helper method to parse a single card's data
  CardModel _parseData({
    required Map<String, dynamic> data,
  }) {
    // Customize this based on the actual NewGame API response structure
    return CardModel(
      cardId: data['id']?.toString() ?? '',
      collectionId: GameConfig.newgame, // Use GameConfig
      name: data['name'] ?? '',
      imageUrl: data['images']?['large'] ?? data['image'] ?? '', // Adjust based on your API's image field
      description: data['description'] ?? '', // Add a relevant description
      additionalData: {
        // Add any additional metadata your API provides
        'type': data['type'] ?? '',
        'rarity': data['rarity'] ?? '',
      },
      isSynced: true,
      updatedAt: DateTime.now(),
    );
  }

  // Helper method to filter and parse a list of cards
  List<CardModel> _filterAndParseData({
    required List<dynamic> data,
  }) {
    // Add any filtering logic if needed (e.g., only "Pokémon" supertype for PokemonApi)
    return data
        .map((cardData) => _parseData(data: cardData))
        .toList();
  }
}

class NewGamePagingStrategy implements PagingStrategy {
  @override
  Map<String, dynamic> buildPage({
    required Map<String, dynamic> current,
    required int offset,
  }) {
    // Customize this based on your API's paging parameters
    return {
      'page': (current['page'] ?? 1) + offset,
      // 'pageSize': 20, // Example: if your API uses page size
    };
  }
}
```

### 🔹 Step 3: Export the Game File

File: `lib/data/datasource/api/~index.dart`

Add an export statement for your new game file:

```dart
export 'pokemon.dart';
export 'newgame.dart'; // <-- Add this
```

---

---

### 🔹 Step 4: Register the Game in `ServiceFactory`

File: `lib/data/datasource/api/@service_factory.dart`

Add your game into the two factory maps:

```dart
class ServiceFactory {
  // ... existing code ...

  static final Map<String, GameApi Function(String baseUrl)> _apiRegistry = {
    GameConfig.pokemon: (baseUrl) => PokemonApi(baseUrl: baseUrl),
    GameConfig.newgame: (baseUrl) => NewGameApi(baseUrl: baseUrl), // <-- Add this
  };

  static final Map<String, PagingStrategy Function()> _pagingRegistry = {
    GameConfig.pokemon: () => PokemonPagingStrategy(),
    GameConfig.newgame: () => NewGamePagingStrategy(), // <-- Add this
  };
}
```

---

### 🔹 Step 5: Add Game Icon Image (Optional but Recommended)

Folder: `assets/image/game/`

1.  Save a `.png` image with the **exact same name** as the game constant defined in `GameConfig`.

2.  For example, if you declared `GameConfig.newgame = 'newgame'`, then save the image as:

    ```
    assets/image/game/newgame.png
    ```

> This image will automatically be used in game lists or UI components that render available games.

---

## ✅ Done\!

You’ve successfully registered a new game\!
Now it will be recognized in the system and available for:

  * Card search via API
  * Paging through card results
  * Deck creation and NFC integration
  * Game icon display in UI (if image is provided)

---

## 🧪 Recommended Testing Checklist

  * [ ] API returns valid data for both `find` and `fetch`
  * [ ] Cards are correctly parsed into `CardModel` objects
  * [ ] Game appears in `GameConfig.supportedGameKeys` (if such a list exists and is used)
  * [ ] Game-specific image asset exists (`/assets/image/game/{game}.png`)
  * [ ] No exceptions thrown when selecting or syncing with the new game

---
