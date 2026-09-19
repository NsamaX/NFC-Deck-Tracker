import '../domain/service/domain_logger.dart';
import 'logger.dart';

class AppDomainLogger implements DomainLogger {
  const AppDomainLogger();
  @override
  void d(String message) => LoggerUtil.d(message);
  @override
  void e(Object message) => LoggerUtil.e(message);
  @override
  void flush() => LoggerUtil.flush();
}
