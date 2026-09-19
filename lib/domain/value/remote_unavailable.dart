class RemoteUnavailableException implements Exception {
  final String message;

  const RemoteUnavailableException(this.message);

  @override
  String toString() => 'RemoteUnavailableException: $message';
}
