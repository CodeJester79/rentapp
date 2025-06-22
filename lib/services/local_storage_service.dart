import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import '../models/property.dart';
import 'package:logging/logging.dart';
import '../utils/logger.dart';

class LocalStorageService {
  final Logger _logger = AppLogger.getLogger('LocalStorageService');
  static const String _propertiesKey = 'local_properties';

  // Guardar una propiedad en almacenamiento local
  Future<Property> saveProperty(Map<String, dynamic> propertyData) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Generar un ID único temporal para la propiedad
      propertyData['id'] = 'local_${DateTime.now().millisecondsSinceEpoch}';

      // Cargar las propiedades existentes
      List<Property> properties = await getLocalProperties();

      // Crear la nueva propiedad con procesamiento S3
      final property = await Property.fromMapWithS3(propertyData);

      // Añadir la nueva propiedad a la lista
      properties.add(property);

      // Convertir la lista a JSON y guardar
      final List<Map<String, dynamic>> propertiesJson =
          properties.map((prop) => prop.toMap()).toList();

      await prefs.setString(_propertiesKey, json.encode(propertiesJson));

      _logger.info('Propiedad guardada localmente con ID: ${property.id}');
      return property;
    } catch (e) {
      _logger.severe('Error al guardar propiedad localmente: $e');
      throw Exception('Error al guardar la propiedad localmente: $e');
    }
  }

  // Guardar una lista de propiedades completa (reemplaza las existentes)
  Future<bool> saveLocalProperties(List<Property> properties) async {
    try {
      _logger.info(
          'Guardando ${properties.length} propiedades en almacenamiento local');
      final prefs = await SharedPreferences.getInstance();

      // Convertir la lista a JSON
      final List<Map<String, dynamic>> propertiesJson =
          properties.map((prop) => prop.toMap()).toList();

      // Guardar la lista completa (reemplazando cualquier dato anterior)
      await prefs.setString(_propertiesKey, json.encode(propertiesJson));

      _logger.info(
          '${properties.length} propiedades guardadas correctamente en almacenamiento local');
      return true;
    } catch (e) {
      _logger
          .severe('Error al guardar propiedades en almacenamiento local: $e');
      return false;
    }
  }

  // Obtener todas las propiedades locales
  Future<List<Property>> getLocalProperties() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Obtener el JSON guardado
      final String? propertiesJson = prefs.getString(_propertiesKey);

      if (propertiesJson == null || propertiesJson.isEmpty) {
        return [];
      }

      // Decodificar JSON
      final List<dynamic> propertiesList = json.decode(propertiesJson);

      // Convertir a lista de propiedades usando el método que procesa S3
      List<Property> properties = [];
      for (var propJson in propertiesList) {
        try {
          // Usamos el método que procesa correctamente las URLs de S3
          Property property = await Property.fromMapWithS3(propJson);
          properties.add(property);
        } catch (e) {
          _logger.warning('Error al procesar propiedad local: $e');
        }
      }

      _logger.info(
          '${properties.length} propiedades locales obtenidas y procesadas con S3');
      return properties;
    } catch (e) {
      _logger.severe('Error al obtener propiedades locales: $e');
      return [];
    }
  }

  // Obtener una propiedad local por su ID
  Future<Property?> getLocalProperty(String id) async {
    try {
      _logger.info('Buscando propiedad local con ID: $id');

      // Obtener todas las propiedades locales como JSON
      final prefs = await SharedPreferences.getInstance();
      final String? propertiesJson = prefs.getString(_propertiesKey);

      if (propertiesJson == null || propertiesJson.isEmpty) {
        return null;
      }

      // Decodificar JSON
      final List<dynamic> propertiesList = json.decode(propertiesJson);

      // Buscar la propiedad con el ID especificado
      Map<String, dynamic>? propMap;
      try {
        propMap = propertiesList.firstWhere(
          (prop) => prop['id'].toString() == id,
        ) as Map<String, dynamic>;
      } catch (e) {
        _logger.warning('Propiedad no encontrada con ID: $id');
        return null;
      }

      // Procesar la propiedad con el método S3
      Property property = await Property.fromMapWithS3(propMap);

      _logger.info(
          'Propiedad local encontrada: ID=${property.id}, Título=${property.title}');
      return property;
    } catch (e) {
      _logger.warning('No se encontró la propiedad local con ID $id: $e');
      return null;
    }
  }

  // Actualizar una propiedad existente
  Future<bool> updateLocalProperty(Property property) async {
    try {
      _logger.info('Actualizando propiedad local con ID: ${property.id}');

      // Cargar las propiedades existentes
      List<Property> properties = await getLocalProperties();

      // Buscar la propiedad por ID
      final index = properties.indexWhere((p) => p.id == property.id);

      if (index == -1) {
        // Si no existe, agregarla a la lista
        _logger.info('Propiedad no encontrada, agregándola a la lista');
        properties.add(property);
      } else {
        // Si existe, reemplazarla
        _logger.info('Propiedad encontrada en índice $index, reemplazándola');
        properties[index] = property;
      }

      // Guardar la lista actualizada
      final List<Map<String, dynamic>> propertiesJson =
          properties.map((prop) => prop.toMap()).toList();

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_propertiesKey, json.encode(propertiesJson));

      _logger
          .info('Propiedad actualizada correctamente en almacenamiento local');
      return true;
    } catch (e) {
      _logger.severe('Error al actualizar propiedad local: $e');
      return false;
    }
  }

  // Eliminar una propiedad
  Future<bool> deleteLocalProperty(String id) async {
    try {
      // Cargar las propiedades existentes
      List<Property> properties = await getLocalProperties();

      // Filtrar la propiedad a eliminar
      properties.removeWhere((p) => p.id == id);

      // Guardar la lista actualizada
      final prefs = await SharedPreferences.getInstance();
      final List<Map<String, dynamic>> propertiesJson =
          properties.map((prop) => prop.toMap()).toList();

      await prefs.setString(_propertiesKey, json.encode(propertiesJson));

      _logger.info('Propiedad eliminada localmente con ID: $id');
      return true;
    } catch (e) {
      _logger.severe('Error al eliminar propiedad local: $e');
      return false;
    }
  }

  // Guardar una imagen localmente (solo guarda la ruta)
  Future<List<String>> saveLocalImages(
      String propertyId, List<String> imagePaths) async {
    try {
      // Obtener la propiedad
      List<Property> properties = await getLocalProperties();
      final index = properties.indexWhere((p) => p.id == propertyId);

      if (index == -1) {
        throw Exception('Propiedad no encontrada');
      }

      // Obtener las imágenes actuales
      List<String> currentImages =
          List<String>.from(properties[index].imageUrls);

      // Añadir las nuevas imágenes
      currentImages.addAll(imagePaths);

      // Actualizar la propiedad
      Map<String, dynamic> propertyData = properties[index].toMap();
      propertyData['imageUrls'] = currentImages;

      // Crear el objeto Property con procesamiento S3 (asíncrono)
      Property property = await Property.fromMapWithS3(propertyData);

      // Guardar los cambios
      await updateLocalProperty(property);

      return currentImages;
    } catch (e) {
      _logger.severe('Error al guardar imágenes localmente: $e');
      throw Exception('Error al guardar imágenes localmente: $e');
    }
  }

  // Actualizar imágenes de una propiedad existente
  Future<List<String>> updatePropertyImages(
      String propertyId, List<String> newImages) async {
    try {
      _logger.info('Actualizando imágenes para propiedad con ID: $propertyId');

      // Cargar las propiedades existentes
      final prefs = await SharedPreferences.getInstance();
      final String? propertiesJson = prefs.getString(_propertiesKey);

      if (propertiesJson == null || propertiesJson.isEmpty) {
        throw Exception('No hay propiedades guardadas');
      }

      // Decodificar JSON
      final List<dynamic> propertiesList = json.decode(propertiesJson);

      // Buscar la propiedad por ID
      final index = propertiesList
          .indexWhere((prop) => prop['id'].toString() == propertyId);

      if (index == -1) {
        throw Exception('Propiedad no encontrada');
      }

      // Obtener los datos de la propiedad
      Map<String, dynamic> propertyData =
          Map<String, dynamic>.from(propertiesList[index]);

      // Actualizar las imágenes
      List<String> currentImages = List<String>.from(newImages);
      propertyData['imageUrls'] = currentImages;

      // Crear el objeto Property con el procesamiento S3
      Property property = await Property.fromMapWithS3(propertyData);

      // Guardar los cambios
      await updateLocalProperty(property);

      return currentImages;
    } catch (e) {
      _logger.severe('Error al actualizar imágenes de propiedad local: $e');
      throw Exception('Error al actualizar imágenes de propiedad local: $e');
    }
  }
}
