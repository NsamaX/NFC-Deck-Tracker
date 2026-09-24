enum CardLookupFailure {
  invalidTag,
  cardNotFound,
  gameNotSupported,
  unavailable,
}

class CardLookupException implements Exception {
  final CardLookupFailure failure;

  const CardLookupException(this.failure);

  @override
  String toString() => 'CardLookupException: ${failure.name}';
}
