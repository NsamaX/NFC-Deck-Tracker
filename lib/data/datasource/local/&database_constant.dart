class DatabaseConstant {
  static const String dbName = 'nfc_deck_tracker.db';
  static const int dbVersion = 1;
  static const List<String> tables = [
    '''
    CREATE TABLE collections (
      collectionId TEXT PRIMARY KEY,
      name TEXT NOT NULL,
      isSynced INTEGER NOT NULL DEFAULT 0 CHECK (isSynced IN (0, 1)),
      updatedAt DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
    );
    ''',
    '''
    CREATE TABLE pages (
      collectionId TEXT NOT NULL,
      paging TEXT NOT NULL,
      UNIQUE(collectionId, paging),
      FOREIGN KEY (collectionId) REFERENCES collections(collectionId) ON DELETE CASCADE
    );
    ''',
    '''
    CREATE TABLE cards (
      collectionId TEXT NOT NULL,
      cardId TEXT NOT NULL,
      name TEXT NOT NULL,
      imageUrl TEXT,
      description TEXT,
      additionalData TEXT,
      isSynced INTEGER NOT NULL DEFAULT 0 CHECK (isSynced IN (0, 1)),
      updatedAt DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
      PRIMARY KEY (collectionId, cardId),
      FOREIGN KEY (collectionId) REFERENCES collections(collectionId) ON DELETE CASCADE
    );
    ''',
    '''
    CREATE TABLE decks (
      deckId TEXT PRIMARY KEY,
      name TEXT NOT NULL,
      isSynced INTEGER NOT NULL DEFAULT 0 CHECK (isSynced IN (0, 1)),
      updatedAt DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
    );
    ''',
    '''
    CREATE TABLE cardsInDeck (
      collectionId TEXT NOT NULL,
      cardId TEXT NOT NULL,
      deckId TEXT NOT NULL,
      count INTEGER NOT NULL,
      FOREIGN KEY (collectionId, cardId) REFERENCES cards(collectionId, cardId) ON DELETE CASCADE,
      FOREIGN KEY (deckId) REFERENCES decks(deckId) ON DELETE CASCADE
    );
    ''',
    '''
    CREATE TABLE records (
      recordId TEXT PRIMARY KEY,
      deckId TEXT NOT NULL,
      createdAt DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
      data TEXT NOT NULL,
      isSynced INTEGER NOT NULL DEFAULT 0 CHECK (isSynced IN (0, 1)),
      updatedAt DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
      FOREIGN KEY (deckId) REFERENCES decks(deckId) ON DELETE CASCADE
    );
    ''',
  ];
  static const List<String> migrations = [];
}
