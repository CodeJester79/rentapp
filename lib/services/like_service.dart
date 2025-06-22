import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:logging/logging.dart';
import '../utils/logger.dart';
import '../services/auth_service.dart'; // Para obtener el token

class LikeService {
  final Logger _logger = AppLogger.getLogger('LikeService');
  final AuthService _authService = AuthService();
  // URL base del servidor
  final String baseUrl = 'http://platform.rentem.click';

  /// Incrementa el contador de likes de una propiedad
  Future<bool> likeProperty(String propertyId) async {
    try {
      _logger.info('Enviando like para la propiedad: $propertyId');

      // Agregar más logs para depurar
      _logger.info('Estado de autenticación: ${_authService.isAuthenticated}');
      _logger.info('Token: ${_authService.token}');
      _logger.info('UserId: ${_authService.userId}');

      // Para debug: si no hay autenticación, intentamos autoLogin
      if (!_authService.isAuthenticated) {
        _logger.info('Intentando auto-login...');
        final autoLoginSuccess = await _authService.tryAutoLogin();
        _logger.info('Auto-login resultado: $autoLoginSuccess');
      }

      // Verificar autenticación nuevamente
      if (!_authService.isAuthenticated) {
        _logger.warning(
            'Usuario no autenticado para dar like aun después del intento de auto-login');

        // Para pruebas: permitir likes aunque no haya autenticación
        // Esto se puede quitar en producción
        _logger.info('Continuando con like sin autenticación para pruebas');
      }

      // Obtener token y userId
      String? token = _authService.token;
      String? userId = _authService.userId;

      // Para pruebas: Si no hay token o userId, usar valores de prueba
      if (token == null || userId == null) {
        _logger.warning('Usando valores de prueba para token o userId');
        token = token ?? 'test_token';
        userId = userId ?? '1';
      }

      // Construir URL para el like
      final likeUrl = '$baseUrl/properties/properties/$propertyId/likes';
      _logger.info('URL de like: $likeUrl');

      // Payload del like
      int userIdInt;
      try {
        userIdInt = int.parse(userId);
      } catch (e) {
        _logger.warning(
            'Error al convertir userId a int: $e. Usando valor predeterminado 1');
        userIdInt = 1; // Valor predeterminado para pruebas
      }

      final payload = {'user_id': userIdInt};

      _logger.info('Enviando payload: ${jsonEncode(payload)}');

      // Enviar solicitud al servidor
      final response = await http.post(
        Uri.parse(likeUrl),
        headers: <String, String>{
          'accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(payload),
      );

      _logger.info('Respuesta del servidor para like: ${response.statusCode}');
      _logger.info('Cuerpo de la respuesta: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        _logger.warning(
            'Error al dar like: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      _logger.severe('Error al dar like: $e');
      return false;
    }
  }

  /// Consulta la URL base correcta del backend
  String getBaseUrl() {
    return baseUrl;
  }
}
