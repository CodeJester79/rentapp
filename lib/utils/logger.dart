import 'package:logging/logging.dart';

/// Clase de utilidad para configurar y usar el sistema de logging
class AppLogger {
  static bool _initialized = false;

  /// Inicializa el sistema de logging con el nivel especificado
  static void init({Level level = Level.INFO}) {
    if (_initialized) return;

    Logger.root.level = level;
    Logger.root.onRecord.listen((record) {
      // Format: [TIME] [LEVEL] [LOGGER_NAME]: MESSAGE
      print(
          '[${record.time}] [${record.level.name}] [${record.loggerName}]: ${record.message}');

      // Si hay una excepción, también la imprime
      if (record.error != null) {
        print('Error: ${record.error}');
        if (record.stackTrace != null) {
          print('Stack trace: ${record.stackTrace}');
        }
      }
    });

    _initialized = true;
  }

  /// Obtiene un logger para el nombre especificado
  static Logger getLogger(String name) {
    if (!_initialized) {
      init();
    }
    return Logger(name);
  }
}
