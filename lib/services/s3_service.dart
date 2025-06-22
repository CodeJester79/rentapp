import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:logging/logging.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/logger.dart';

class S3Service {
  final Logger _logger = AppLogger.getLogger('S3Service');

  // Nombre del bucket
  static const String _bucketName = 'rentapp-datachar';

  // URL del servicio proxy para S3
  static const String _proxyBaseUrl = 'http://platform.rentem.click';

  // Constante para la clave del token (debe coincidir con AuthService)
  static const String _tokenKey = 'auth_token';

  // Obtener el token de autenticación de SharedPreferences
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  // Obtener las URLs de fotos para una propiedad específica usando el endpoint correcto
  Future<List<String>> getPropertyPhotos(String propertyId) async {
    try {
      final token = await _getToken();

      if (token == null) {
        _logger.warning('Token de autenticación no disponible');
        return [];
      }

      // Usar el endpoint específico para obtener fotos de una propiedad
      final response = await http.get(
        Uri.parse('$_proxyBaseUrl/properties/properties/$propertyId/photos'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json'
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> photosData = json.decode(response.body);
        _logger.info(
            'Fotos obtenidas para propiedad $propertyId: ${photosData.length} fotos');

        // Extraer las URLs de las fotos de la respuesta
        List<String> photoUrls = [];
        for (var photoData in photosData) {
          if (photoData is Map<String, dynamic> &&
              photoData.containsKey('photo_url')) {
            photoUrls.add(photoData['photo_url'].toString());
          }
        }

        _logger.info('URLs de fotos procesadas: $photoUrls');
        return photoUrls;
      } else {
        _logger.warning(
            'Error al obtener fotos: ${response.statusCode} - ${response.body}');
        return [];
      }
    } catch (e) {
      _logger.severe('Error al obtener fotos para propiedad $propertyId: $e');
      return [];
    }
  }

  // Retorna la URL con token de acceso para una imagen en S3
  Future<String> getImageUrlWithProxy(String s3Key) async {
    try {
      // Si la URL ya es una URL completa, extraer la clave
      if (s3Key.startsWith('https://')) {
        final uri = Uri.parse(s3Key);
        final pathSegments = uri.pathSegments;
        // La clave es todo excepto el nombre del bucket
        s3Key = pathSegments.skip(1).join('/');
      }

      // Construir URL proxy para la API del backend
      const proxyUrl = '$_proxyBaseUrl/properties/s3-image-proxy';

      // Hacer la solicitud al proxy
      final response = await http.post(
        Uri.parse(proxyUrl),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'key': s3Key,
        }),
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        final signedUrl = jsonResponse['signed_url'];
        _logger.info('URL firmada generada para $s3Key: $signedUrl');
        return signedUrl;
      } else {
        _logger.warning(
            'Error al obtener URL firmada: ${response.statusCode} - ${response.body}');
        // Si falla, devolver una URL con credenciales básicas (no es lo ideal pero es un fallback)
        return _generateBasicImageUrl(s3Key);
      }
    } catch (e) {
      _logger.severe('Error al generar URL firmada: $e');
      // Si falla, devolver una URL con credenciales básicas
      return _generateBasicImageUrl(s3Key);
    }
  }

  // Genera una URL básica para la imagen
  String _generateBasicImageUrl(String s3Key) {
    final publicUrl = 'https://$_bucketName.s3.amazonaws.com/$s3Key';
    _logger.info('URL básica generada para $s3Key: $publicUrl');
    return publicUrl;
  }

  // Procesa una lista de URLs de S3 y devuelve URLs procesadas
  Future<List<String>> processImageUrls(List<String> originalUrls) async {
    _logger.info('Procesando ${originalUrls.length} URLs de imágenes');

    List<String> processedUrls = [];

    for (var url in originalUrls) {
      try {
        if (url.contains('s3.amazonaws.com')) {
          // Es una URL de S3, procesar para obtener acceso
          final processedUrl = await getImageUrlWithProxy(url);
          processedUrls.add(processedUrl);
        } else {
          // No es una URL de S3, usar tal cual
          processedUrls.add(url);
        }
      } catch (e) {
        _logger.severe('Error al procesar URL de imagen $url: $e');
        // En caso de error, añadir la URL original
        processedUrls.add(url);
      }
    }

    _logger.info('URLs procesadas: $processedUrls');
    return processedUrls;
  }
}
