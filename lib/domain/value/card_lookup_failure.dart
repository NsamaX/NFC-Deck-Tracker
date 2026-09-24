enum CardLookupFailure {
  invalidTag,
  cardNotFound,
  gameNotSupported,
}

class CardLookupException implements Exception {
  final CardLookupFailure failure;

  const CardLookupException(this.failure);

  @override
  String toString() => 'CardLookupException: ${failure.name}';
}
