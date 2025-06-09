<h1 align="center">🃏 How to Add a New Game</h1>

## Overview

This guide explains how to integrate a **new Trading Card Game (TCG)** into the NFC Deck Tracker app.  
Each game must be registered in the application along with its associated **API provider** and **paging strategy** to support card searching, deck tracking, and real-time updates via NFC.

---

## 📌 Prerequisites

- The game must have a publicly accessible card API (REST preferred)
- Card data must include at minimum: `id`, `name`, `image`, and optional metadata

---

## ✅ Step-by-Step Instructions

---

### 🔹 Step 1: Register Game in `Game`

File: `lib/.config/game.dart`

1. Add a new constant for your game ID.
2. Define API URLs under each environment (`development`, `production`).

```dart
static const String newgame = 'newgame';

static const Map<String, Map<String, String>> environments = {
  'development': {
    newgame: 'https://your-newgame-api.com/v1/', // <-- Add this
  },
  'production': {
    newgame: '', // <-- Add this when ready
  },
};
````

---

### 🔹 Step 2: Create Game API and Paging Strategy

Folder: `lib/data/datasource/api/`

Create a new file named `{your_game}.dart` (e.g., `newgame.dart`) with:

* A class implementing `GameApi`:

  * `findCard(...)`
  * `fetchCard(...)`

* A class implementing `PagingStrategy`:

  * `buildPage(...)`

```dart
class NewGameApi extends BaseApi implements GameApi {
  NewGameApi(String baseUrl) : super(baseUrl);

  @override
  Future<CardModel> findCard({required String cardId}) async {
    final response = await getRequest('cards/$cardId');
    final data = decodeResponse(response);
    return CardModel(
      cardId: data['id'] ?? '',
      collectionId: Game.newgame,
      name: data['name'] ?? '',
      imageUrl: data['image'] ?? '',
      updatedAt: DateTime.now(),
      additionalData: {}, // Customize as needed
    );
  }

  @override
  Future<List<CardModel>> fetchCard({required Map<String, dynamic> page}) async {
    final response = await getRequest('cards', page.map((k, v) => MapEntry(k, v.toString())));
    final body = decodeResponse(response);
    final List<dynamic> results = body['data'] ?? [];

    return results.map((e) => CardModel(
      cardId: e['id'],
      collectionId: Game.newgame,
      name: e['name'],
      imageUrl: e['image'],
      updatedAt: DateTime.now(),
      additionalData: {},
    )).toList();
  }
}

class NewGamePagingStrategy implements PagingStrategy {
  @override
  Map<String, dynamic> buildPage({required Map<String, dynamic> current, required int offset}) {
    return {
      'page': (current['page'] ?? 1) + offset,
    };
  }
}
```

### 🔹 Step 3: Export the Game File

File: `lib/data/datasource/api/~index.dart`

Add an export statement for your new game file:

```dart
export 'newgame.dart'; // <-- Add this
```

---

---

### 🔹 Step 4: Register the Game in `ServiceFactory`

File: `lib/data/datasource/api/@service_factory.dart`

Add your game into the two factory maps:

```dart
static final Map<String, GameApi Function(String)> _apiRegistry = {
  Game.newgame: (baseUrl) => NewGameApi(baseUrl), // <-- Add this
};

static final Map<String, PagingStrategy Function()> _pagingRegistry = {
  Game.newgame: () => NewGamePagingStrategy(), // <-- Add this
};
```

---

### 🔹 Step 5: Add Game Icon Image (Optional but Recommended)

Folder: `assets/image/game/`

1. Save a `.png` image with the **exact same name** as the game constant defined in `Game`.
2. For example, if you declared `Game.newgame = 'newgame'`, then save the image as:

```
assets/image/game/newgame.png
```

> This image will automatically be used in game lists or UI components that render available games.

---

## ✅ Done!

You’ve successfully registered a new game! 🎉
Now it will be recognized in the system and available for:

* Card search via API
* Paging through card results
* Deck creation and NFC integration
* Game icon display in UI (if image is provided)

---

## 🧪 Recommended Testing Checklist

* [ ] API returns valid data for both `findCard` and `fetchCard`
* [ ] Cards are correctly saved to local storage
* [ ] Game appears in `Game.supportedGameKeys`
* [ ] Game-specific image asset exists (`/assets/image/game/{game}.png`)
* [ ] No exceptions thrown when selecting or syncing with the new game

---
