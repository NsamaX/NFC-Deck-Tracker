abstract interface class DomainLogger {
  void d(String message);
  void e(Object message);
  void flush();
}

class SilentDomainLogger implements DomainLogger {
  const SilentDomainLogger();
  @override
  void d(String message) {}
  @override
  void e(Object message) {}
  @override
  void flush() {}
}
