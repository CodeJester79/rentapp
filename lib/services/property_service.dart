import 'dart:io';
import 'dart:convert'; // Added the missing import for JSON functionality
import 'dart:math' as math;
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:logging/logging.dart';
import '../models/property.dart';
import '../models/comment.dart';
import '../models/inquiry.dart';
import '../utils/logger.dart';
import 'local_storage_service.dart';

class PropertyService {
  // Logger para esta clase
  final Logger _logger = AppLogger.getLogger('PropertyService');

  // URL base del API
  final String baseUrl = 'http://platform.rentem.click';

  // Constante para la clave del token (debe coincidir con AuthService)
  static const String _tokenKey = 'auth_token';

  // Servicio de almacenamiento local
  final LocalStorageService _localStorageService = LocalStorageService();

  // Obtener token para autenticación
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  // Headers para las solicitudes autenticadas
  Future<Map<String, String>> _getAuthHeaders() async {
    final token = await _getToken();
    if (token == null) {
      throw Exception('Token de autenticación no disponible');
    }
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // 1. Obtener todas las propiedades
  Future<List<Property>> getAllProperties({bool forceRefresh = true}) async {
    try {
      _logger.info(
          'PropertyService.getAllProperties - forceRefresh: $forceRefresh');

      // Si no se fuerza la actualización, intentar cargar desde local storage
      if (!forceRefresh) {
        final localProperties = await _localStorageService.getLocalProperties();
        if (localProperties.isNotEmpty) {
          _logger.info(
              'PropertyService.getAllProperties - Usando propiedades locales: ${localProperties.length}');
          return localProperties;
        }
      }

      // Si se fuerza la actualización o no hay datos locales, cargar del servidor
      final url = '$baseUrl/properties/properties';
      _logger.info('🚀 PROPERTIES REQUEST:');
      _logger.info('URL: $url');
      _logger.info('Headers: {accept: application/json}');

      final response = await http.get(
        Uri.parse(url),
        headers: {'accept': 'application/json'},
      ).timeout(const Duration(seconds: 15));

      _logger.info('📨 PROPERTIES RESPONSE:');
      _logger.info('Status Code: ${response.statusCode}');
      _logger.info('Response Headers: ${response.headers}');
      _logger.info('Response Body Length: ${response.body.length}');

      if (response.statusCode == 200) {
        // Procesar la respuesta manualmente para mayor control
        final String responseBody = response.body;
        _logger.info(
            'Cuerpo de la respuesta (primeros 200 caracteres): ${responseBody.substring(0, math.min(responseBody.length, 200))}');

        // Decodificar el JSON a una lista de Maps
        final List<dynamic> jsonList =
            json.decode(responseBody) as List<dynamic>;
        _logger
            .info('Lista JSON decodificada con ${jsonList.length} elementos');

        // Convertir cada elemento del JSON a un objeto Property usando el método que procesa S3
        List<Property> properties = [];
        for (var i = 0; i < jsonList.length; i++) {
          try {
            Map<String, dynamic> propertyData =
                jsonList[i] as Map<String, dynamic>;
            _logger.info('Procesando propiedad ${i + 1}/${jsonList.length}');

            // Usar el nuevo método que maneja las imágenes de S3
            Property property = await Property.fromMapWithS3(propertyData);
            properties.add(property);

            _logger.info(
                'Propiedad procesada - ID: ${property.id}, Título: ${property.title}');
            _logger.info('URLs de imágenes: ${property.imageUrls}');
          } catch (e) {
            _logger.warning('Error al procesar propiedad ${i + 1}: $e');
          }
        }

        _logger
            .info('Procesadas ${properties.length} propiedades correctamente');

        // Guardar en local storage para uso futuro
        await _localStorageService.saveLocalProperties(properties);

        return properties;
      } else {
        _logger.severe('❌ Error al cargar propiedades:');
        _logger.severe('Status Code: ${response.statusCode}');
        _logger.severe('Response Body: ${response.body}');
        throw Exception('Error al cargar propiedades: ${response.statusCode}');
      }
    } catch (e) {
      _logger.severe('💥 Error en getAllProperties: $e');
      _logger.severe('Error type: ${e.runtimeType}');
      
      // Intentar cargar desde storage local como fallback
      try {
        final localProperties = await _localStorageService.getLocalProperties();
        if (localProperties.isNotEmpty) {
          _logger.info('📱 Usando propiedades desde storage local como fallback');
          return localProperties;
        }
      } catch (localError) {
        _logger.warning('Error al cargar desde storage local: $localError');
      }
      
      throw Exception('Error al cargar propiedades: $e');
    }
  }

  // 2. Obtener una propiedad específica
  Future<Property> getProperty(String propertyId) async {
    try {
      _logger.info(
          'PropertyService.getProperty - Solicitando propiedad con ID: $propertyId');

      // Intentar primero obtener de la caché local
      try {
        Property? localProperty =
            await _localStorageService.getLocalProperty(propertyId);
        if (localProperty != null) {
          _logger.info(
              'PropertyService.getProperty - Propiedad encontrada en local storage');
          return localProperty;
        } else {
          _logger.info(
              'PropertyService.getProperty - Propiedad no encontrada en local storage');
        }
      } catch (e) {
        _logger.warning('Error al obtener propiedad local: $e');
      }

      // Si no está en local storage, obtener del servidor
      final response = await http.get(
        Uri.parse('$baseUrl/properties/properties/$propertyId'),
        headers: {'accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        final propertyData = json.decode(response.body) as Map<String, dynamic>;
        _logger.info(
            'Datos de propiedad recibidos del servidor: ${propertyData.toString().substring(0, math.min(propertyData.toString().length, 200))}');

        // Usar el nuevo método que maneja las imágenes de S3
        Property property = await Property.fromMapWithS3(propertyData);

        // Guardar en local storage
        await _localStorageService.updateLocalProperty(property);

        _logger.info(
            'Propiedad procesada con éxito - ID: ${property.id}, Imágenes: ${property.imageUrls}');
        return property;
      } else {
        throw Exception('Error al cargar la propiedad: ${response.statusCode}');
      }
    } catch (e) {
      _logger.severe('Error en getProperty: $e');
      throw Exception('Error al cargar la propiedad: $e');
    }
  }

  // 3. Crear una nueva propiedad
  Future<Property> createProperty(Map<String, dynamic> propertyData) async {
    try {
      // Asegurarse de que los datos tienen el formato correcto que espera la API
      Map<String, dynamic> formattedData = {
        "title": propertyData['title'],
        "description": propertyData['description'],
        "price": propertyData['price'],
        "address": propertyData['location'], // Mapeando 'location' a 'address'
        "city": propertyData['city'] ??
            "Santo Domingo", // Valores por defecto para campos requeridos
        "state": propertyData['state'] ?? "DN",
        "zip_code": propertyData['zip_code'] ?? "10001",
        "property_type": "apartment",
        "bedrooms": propertyData['bedrooms'],
        "bathrooms": 1, // Valor por defecto
        "square_feet": propertyData[
            'squareMeters'], // Mapeando 'squareMeters' a 'square_feet'
        "broker_id": 1 // ID por defecto
      };

      _logger.info(
          'Enviando datos de propiedad al servidor: ${json.encode(formattedData)}');

      // Intentar crear la propiedad en el servidor
      final response = await http.post(
        Uri.parse('$baseUrl/properties/properties'),
        headers: await _getAuthHeaders(),
        body: json.encode(formattedData),
      );

      _logger.info('Respuesta del servidor: ${response.statusCode}');
      _logger.fine('Cuerpo de la respuesta: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Si la creación es exitosa, convertir la respuesta a un objeto Property
        _logger.info('Propiedad creada exitosamente en el servidor');
        final propertyJson = json.decode(response.body);
        return Property.fromMap(propertyJson);
      } else {
        _logger
            .warning('Error al crear propiedad en servidor: ${response.body}');
        // Si falla la creación en el servidor, intentar guardar localmente
        _logger.info('Intentando guardar propiedad localmente...');
        return await _localStorageService.saveProperty(propertyData);
      }
    } catch (e) {
      _logger.severe('Exception en createProperty: $e');
      // Si hay una excepción (ej. error de conexión), usar almacenamiento local
      _logger.info('Error de conexión, guardando propiedad localmente...');
      return await _localStorageService.saveProperty(propertyData);
    }
  }

  // 4. Actualizar una propiedad
  Future<Property> updateProperty(
      String propertyId, Map<String, dynamic> propertyData) async {
    try {
      // Asegurar que el ID se incluya en los datos
      propertyData['id'] = propertyId;

      // Intentar actualizar en el servidor
      final response = await http.put(
        Uri.parse('$baseUrl/properties/properties/$propertyId'),
        headers: await _getAuthHeaders(),
        body: json.encode(propertyData),
      );

      if (response.statusCode == 200) {
        final Property property = Property.fromMap(json.decode(response.body));
        // Actualizar en local storage
        await _localStorageService.updateLocalProperty(property);
        return property;
      } else {
        _logger.warning(
            'Error al actualizar propiedad en servidor: ${response.body}');
        // Si falla la actualización en el servidor, actualizar localmente
        final Property property = Property.fromMap(propertyData);
        final bool success =
            await _localStorageService.updateLocalProperty(property);
        if (success) {
          return property;
        } else {
          throw Exception('Error al actualizar propiedad');
        }
      }
    } catch (e) {
      _logger.severe('Exception en updateProperty: $e');
      // Si hay una excepción, usar almacenamiento local
      final Property property = Property.fromMap(propertyData);
      final bool success =
          await _localStorageService.updateLocalProperty(property);
      if (success) {
        return property;
      } else {
        throw Exception('Error al actualizar propiedad: $e');
      }
    }
  }

  // 5. Eliminar una propiedad
  Future<bool> deleteProperty(String propertyId) async {
    try {
      // Intentar eliminar en el servidor
      final response = await http.delete(
        Uri.parse('$baseUrl/properties/properties/$propertyId'),
        headers: await _getAuthHeaders(),
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        _logger.warning(
            'Error al eliminar propiedad en servidor: ${response.body}');
        // Si falla la eliminación en el servidor, intentar eliminar localmente
        return await _localStorageService.deleteLocalProperty(propertyId);
      }
    } catch (e) {
      _logger.severe('Exception en deleteProperty: $e');
      // Si hay una excepción, usar almacenamiento local
      return await _localStorageService.deleteLocalProperty(propertyId);
    }
  }

  // 6. Subir imágenes a una propiedad
  Future<bool> uploadPropertyImages(
      String propertyId, List<File> images) async {
    try {
      final token = await _getToken();
      final uri =
          Uri.parse('$baseUrl/properties/properties/$propertyId/photos');

      var request = http.MultipartRequest('POST', uri);
      request.headers.addAll({
        'Authorization': 'Bearer $token',
      });

      // Añadir cada imagen como un archivo multipart
      for (var i = 0; i < images.length; i++) {
        final file = images[i];
        final stream = http.ByteStream(file.openRead());
        final length = await file.length();

        final multipartFile = http.MultipartFile(
          'photos', // Cambiado de 'images' a 'photos' para coincidir con lo que espera el servidor
          stream,
          length,
          filename: 'image_${DateTime.now().millisecondsSinceEpoch}_$i.jpg',
        );

        request.files.add(multipartFile);
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        return true;
      } else {
        _logger.warning('Error al subir imágenes: ${response.body}');
        throw Exception('Error al subir las imágenes');
      }
    } catch (e) {
      _logger.severe('Exception en uploadPropertyImages: $e');
      throw Exception('Error al subir las imágenes');
    }
  }

  // 7. Obtener todas las imágenes de una propiedad
  Future<List<String>> getPropertyImages(String propertyId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/properties/properties/$propertyId/photos'),
        headers: await _getAuthHeaders(),
      );

      if (response.statusCode == 200) {
        final List<dynamic> photosJson = json.decode(response.body);
        return photosJson.map((json) => json['url'] as String).toList();
      } else {
        _logger.warning('Error al obtener imágenes: ${response.body}');
        throw Exception('Error al obtener las imágenes');
      }
    } catch (e) {
      _logger.severe('Exception en getPropertyImages: $e');
      throw Exception('Error al conectar con el servidor');
    }
  }

  // 8. Borrar una imagen de una propiedad
  Future<bool> deletePropertyImage(String propertyId, String photoId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/properties/properties/$propertyId/photos/$photoId'),
        headers: await _getAuthHeaders(),
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        _logger.warning('Error al eliminar imagen: ${response.body}');
        throw Exception('Error al eliminar la imagen');
      }
    } catch (e) {
      _logger.severe('Exception en deletePropertyImage: $e');
      throw Exception('Error al conectar con el servidor');
    }
  }

  // 9. Verificar si una propiedad está en favoritos
  Future<bool> isPropertyLiked(String propertyId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/properties/likes/$propertyId'),
        headers: await _getAuthHeaders(),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        return responseData['isLiked'] ?? false;
      } else {
        return false;
      }
    } catch (e) {
      _logger.severe('Exception en isPropertyLiked: $e');
      return false;
    }
  }

  // 10. Añadir o quitar una propiedad de favoritos
  Future<bool> togglePropertyLike(String propertyId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/properties/likes/$propertyId/toggle'),
        headers: await _getAuthHeaders(),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        return responseData['isLiked'] ?? false;
      } else {
        _logger
            .warning('Error al cambiar estado de favorito: ${response.body}');
        throw Exception('Error al cambiar estado de favorito');
      }
    } catch (e) {
      _logger.severe('Exception en togglePropertyLike: $e');
      throw Exception('Error al conectar con el servidor');
    }
  }

  // 11. Añadir un comentario a una propiedad
  Future<Comment> addComment(String propertyId, String text) async {
    try {
      final Map<String, dynamic> commentData = {
        'propertyId': propertyId,
        'text': text,
      };

      final response = await http.post(
        Uri.parse('$baseUrl/properties/properties/$propertyId/comments'),
        headers: await _getAuthHeaders(),
        body: json.encode(commentData),
      );

      if (response.statusCode == 201) {
        return Comment.fromMap(json.decode(response.body));
      } else {
        _logger.warning('Error al añadir comentario: ${response.body}');
        throw Exception('Error al añadir comentario');
      }
    } catch (e) {
      _logger.severe('Exception en addComment: $e');
      throw Exception('Error al conectar con el servidor');
    }
  }

  // 12. Añadir una consulta para una propiedad
  Future<Inquiry> addInquiry(
      String propertyId, String message, String contactInfo) async {
    try {
      final Map<String, dynamic> inquiryData = {
        'propertyId': propertyId,
        'message': message,
        'contactInfo': contactInfo,
      };

      final response = await http.post(
        Uri.parse('$baseUrl/properties/properties/$propertyId/inquiries'),
        headers: await _getAuthHeaders(),
        body: json.encode(inquiryData),
      );

      if (response.statusCode == 201) {
        return Inquiry.fromMap(json.decode(response.body));
      } else {
        _logger.warning('Error al añadir consulta: ${response.body}');
        throw Exception('Error al añadir consulta');
      }
    } catch (e) {
      _logger.severe('Exception en addInquiry: $e');
      throw Exception('Error al conectar con el servidor');
    }
  }

  // 13. Dar like a una propiedad
  Future<bool> likeProperty(String propertyId) async {
    try {
      final authHeaders = await _getAuthHeaders();
      final token = authHeaders['Authorization']?.split(' ').last;
      if (token == null) {
        throw Exception('Authentication token is not available');
      }

      // Decode the token to get the user ID
      final payload = json.decode(
          ascii.decode(base64.decode(base64.normalize(token.split('.')[1]))));
      final userId = payload['user_id'];

      if (userId == null) {
        throw Exception('User ID is not available in the token');
      }

      final Map<String, dynamic> requestBody = {
        'user_id': userId,
      };

      final response = await http.post(
        Uri.parse('$baseUrl/properties/properties/$propertyId/likes'),
        headers: await _getAuthHeaders(),
        body: json.encode(requestBody),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        _logger.warning('Error al dar like: ${response.body}');
        throw Exception('Error al dar like a la propiedad');
      }
    } catch (e) {
      _logger.severe('Exception en likeProperty: $e');
      throw Exception('Error al conectar con el servidor');
    }
  }

  // 14. Obtener likes de una propiedad
  Future<int> getPropertyLikes(String propertyId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/properties/properties/$propertyId/likes'),
        headers: await _getAuthHeaders(),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return data['count'] ?? 0;
      } else {
        _logger.warning('Error al obtener likes: ${response.body}');
        throw Exception('Error al obtener los likes');
      }
    } catch (e) {
      _logger.severe('Exception en getPropertyLikes: $e');
      throw Exception('Error al conectar con el servidor');
    }
  }

  // 15. Añadir un comentario a una propiedad
  Future<bool> addPropertyComment(String propertyId, String comment) async {
    try {
      final authHeaders = await _getAuthHeaders();
      final token = authHeaders['Authorization']?.split(' ').last;
      if (token == null) {
        throw Exception('Authentication token is not available');
      }

      // Decode the token to get the user ID
      final payload = json.decode(
          ascii.decode(base64.decode(base64.normalize(token.split('.')[1]))));
      final userId = payload['user_id'];

      if (userId == null) {
        throw Exception('User ID is not available in the token');
      }

      final Map<String, dynamic> requestBody = {
        'user_id': userId,
        'content': comment,
      };

      final response = await http.post(
        Uri.parse('$baseUrl/properties/properties/$propertyId/comments'),
        headers: await _getAuthHeaders(),
        body: json.encode(requestBody),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        _logger.warning('Error al añadir comentario: ${response.body}');
        throw Exception('Error al añadir el comentario');
      }
    } catch (e) {
      _logger.severe('Exception en addPropertyComment: $e');
      throw Exception('Error al conectar con el servidor');
    }
  }

  // 16. Obtener comentarios de una propiedad
  Future<List<Map<String, dynamic>>> getPropertyComments(
      String propertyId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/properties/properties/$propertyId/comments'),
        headers: await _getAuthHeaders(),
      );

      if (response.statusCode == 200) {
        final List<dynamic> commentsJson = json.decode(response.body);
        return commentsJson
            .map((json) => json as Map<String, dynamic>)
            .toList();
      } else {
        _logger.warning('Error al obtener comentarios: ${response.body}');
        throw Exception('Error al obtener los comentarios');
      }
    } catch (e) {
      _logger.severe('Exception en getPropertyComments: $e');
      throw Exception('Error al conectar con el servidor');
    }
  }

  // 17. Crear una consulta (inquiry) sobre una propiedad
  Future<bool> createPropertyInquiry(String propertyId, String message) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/properties/properties/$propertyId/inquiries'),
        headers: await _getAuthHeaders(),
        body: json.encode({'message': message}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        _logger.warning('Error al crear consulta: ${response.body}');
        throw Exception('Error al crear la consulta');
      }
    } catch (e) {
      _logger.severe('Exception en createPropertyInquiry: $e');
      throw Exception('Error al conectar con el servidor');
    }
  }

  // 18. Obtener consultas (inquiries) de una propiedad
  Future<List<Map<String, dynamic>>> getPropertyInquiries(
      String propertyId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/properties/properties/$propertyId/inquiries'),
        headers: await _getAuthHeaders(),
      );

      if (response.statusCode == 200) {
        final List<dynamic> inquiriesJson = json.decode(response.body);
        return inquiriesJson
            .map((json) => json as Map<String, dynamic>)
            .toList();
      } else {
        _logger.warning('Error al obtener consultas: ${response.body}');
        throw Exception('Error al obtener las consultas');
      }
    } catch (e) {
      _logger.severe('Exception en getPropertyInquiries: $e');
      throw Exception('Error al conectar con el servidor');
    }
  }

  // 19. Actualizar el estado de una propiedad
  Future<bool> updatePropertyStatus(String propertyId, String status) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/properties/properties/$propertyId/status'),
        headers: await _getAuthHeaders(),
        body: json.encode({'status': status}),
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        _logger.warning('Error al actualizar estado: ${response.body}');
        throw Exception('Error al actualizar el estado');
      }
    } catch (e) {
      _logger.severe('Exception en updatePropertyStatus: $e');
      throw Exception('Error al conectar con el servidor');
    }
  }

  // 20. Obtener el estado de una propiedad
  Future<String> getPropertyStatus(String propertyId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/properties/properties/$propertyId/status'),
        headers: await _getAuthHeaders(),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return data['status'] ?? 'unknown';
      } else {
        _logger.warning('Error al obtener estado: ${response.body}');
        throw Exception('Error al obtener el estado de la propiedad');
      }
    } catch (e) {
      _logger.severe('Exception en getPropertyStatus: $e');
      throw Exception('Error al conectar con el servidor');
    }
  }

  Future<List<Property>> getProperties() async {
    try {
      final url = '$baseUrl/properties';
      _logger.info('🚀 GET PROPERTIES REQUEST:');
      _logger.info('URL: $url');
      _logger.info('Headers: {Content-Type: application/json}');

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 15));

      _logger.info('📨 GET PROPERTIES RESPONSE:');
      _logger.info('Status Code: ${response.statusCode}');
      _logger.info('Response Headers: ${response.headers}');
      _logger.info('Response Body Length: ${response.body.length}');

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        _logger.info('Retrieved ${data.length} properties');

        return data.map((json) {
          // Using fromMap instead of fromJson which doesn't exist
          final property = Property.fromMap(json);
          _logger.info(
              'Property ID: ${property.id}, Primary Photo: ${property.getPrimaryPhoto()?.photoUrl ?? "None"}');
          return property;
        }).toList();
      } else {
        _logger.severe('❌ Error al cargar propiedades (getProperties):');
        _logger.severe('Status Code: ${response.statusCode}');
        _logger.severe('Response Body: ${response.body}');
        throw Exception('Failed to load properties: ${response.statusCode}');
      }
    } catch (e) {
      _logger.severe('💥 Exception in getProperties: $e');
      _logger.severe('Error type: ${e.runtimeType}');
      throw Exception('Error getting properties: $e');
    }
  }

  // 21. Obtener propiedades liked por el usuario
  Future<List<Property>> getLikedProperties() async {
    try {
      final authHeaders = await _getAuthHeaders();
      final token = authHeaders['Authorization']?.split(' ').last;
      if (token == null) {
        throw Exception('Authentication token is not available');
      }

      // Decode the token to get the user ID
      final payload = json.decode(
          ascii.decode(base64.decode(base64.normalize(token.split('.')[1]))));
      final userId = payload['user_id'];

      if (userId == null) {
        throw Exception('User ID is not available in the token');
      }

      final response = await http.get(
        Uri.parse('$baseUrl/user/$userId/likes'),
        headers: await _getAuthHeaders(),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Property.fromMap(json)).toList();
      } else {
        _logger
            .warning('Failed to load liked properties: ${response.statusCode}');
        throw Exception('Failed to load liked properties');
      }
    } catch (e) {
      _logger.severe('Exception in getLikedProperties: $e');
      throw Exception('Error getting liked properties: $e');
    }
  }
}
