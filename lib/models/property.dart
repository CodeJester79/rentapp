import 'comment.dart';
import 'inquiry.dart';
import 'package:logging/logging.dart';
import '../utils/logger.dart';
import '../services/s3_service.dart';
import 'dart:math' as math;

class Property {
  static final Logger _logger = AppLogger.getLogger('Property');
  static final S3Service _s3Service = S3Service(); // Instancia del servicio S3

  final String id;
  final String title;
  final String description;
  final double price;
  final String location;
  final int bedrooms;
  final double squareMeters;
  final List<String>
      imageUrls; // URLs de imágenes, ahora procesadas por S3Service
  final String ownerId;
  final DateTime createdAt;
  final List<Comment> comments;
  final List<Inquiry> inquiries;
  final bool favorite;
  int likes; // Restaurado el campo likes
  final List<PropertyPhoto> photos;

  Property({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.location,
    required this.bedrooms,
    required this.squareMeters,
    required this.imageUrls,
    required this.ownerId,
    required this.createdAt,
    required this.comments,
    required this.inquiries,
    this.favorite = false,
    this.likes = 0, // Valor por defecto
    required this.photos,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'price': price,
      'location': location,
      'bedrooms': bedrooms,
      'squareMeters': squareMeters,
      'imageUrls': imageUrls, // Las URLs ya procesadas se serializan
      'ownerId': ownerId,
      'createdAt': createdAt.toIso8601String(),
      'comments': comments.map((comment) => comment.toMap()).toList(),
      'inquiries': inquiries.map((inquiry) => inquiry.toMap()).toList(),
      'likes': likes, // Agregar el campo likes al mapa
    };
  }

  // Método factory sincrónico para mantener compatibilidad con código existente
  factory Property.fromMap(Map<String, dynamic> map) {
    try {
      _logger.info(
          'Property.fromMap - Procesando JSON: ${map.toString().substring(0, math.min(map.toString().length, 200))}');

      // Para id, asegurarnos de que es string
      final String propertyId = map['id']?.toString() ?? '0';

      // Para title, usar title o si no existe, usar property_title
      final String propertyTitle =
          map['title']?.toString() ?? map['property_title']?.toString() ?? '';

      // Para description, usar description o si no existe, usar property_description
      final String propertyDescription = map['description']?.toString() ??
          map['property_description']?.toString() ??
          '';

      // Para price, usar price o si no existe, price_per_month
      double propertyPrice = 0.0;
      if (map['price'] != null) {
        propertyPrice = double.tryParse(map['price'].toString()) ?? 0.0;
      } else if (map['price_per_month'] != null) {
        propertyPrice =
            double.tryParse(map['price_per_month'].toString()) ?? 0.0;
      }

      // Para location, usar location o si no existe, combinar address, city, state
      String propertyLocation = '';
      if (map['location'] != null) {
        propertyLocation = map['location'].toString();
      } else {
        // Construir location a partir de address, city, state si existen
        final List<String> locationParts = [];

        if (map['address'] != null && map['address'].toString().isNotEmpty) {
          locationParts.add(map['address'].toString());
        }

        if (map['city'] != null && map['city'].toString().isNotEmpty) {
          locationParts.add(map['city'].toString());
        }

        if (map['state'] != null && map['state'].toString().isNotEmpty) {
          locationParts.add(map['state'].toString());
        }

        if (locationParts.isNotEmpty) {
          propertyLocation = locationParts.join(', ');
        }
      }

      // Para bedrooms, usar bedrooms o si no existe num_bedrooms
      int propertyBedrooms = 0;
      if (map['bedrooms'] != null) {
        propertyBedrooms = int.tryParse(map['bedrooms'].toString()) ?? 0;
      } else if (map['num_bedrooms'] != null) {
        propertyBedrooms = int.tryParse(map['num_bedrooms'].toString()) ?? 0;
      }

      // Para squareMeters, usar squareMeters o si no existe, square_feet y convertir
      double propertySquareMeters = 0.0;
      if (map['squareMeters'] != null) {
        propertySquareMeters =
            double.tryParse(map['squareMeters'].toString()) ?? 0.0;
      } else if (map['square_meters'] != null) {
        propertySquareMeters =
            double.tryParse(map['square_meters'].toString()) ?? 0.0;
      } else if (map['square_feet'] != null) {
        // Convertir pies cuadrados a metros cuadrados (1 pie cuadrado = 0.092903 metros cuadrados)
        double squareFeet =
            double.tryParse(map['square_feet'].toString()) ?? 0.0;
        propertySquareMeters = squareFeet * 0.092903;
      }

      // Para imageUrls, procesar correctamente el campo photos
      List<String> propertyImageUrls = [];
      if (map['imageUrls'] != null) {
        _logger.info('Property.fromMap - Campo imageUrls encontrado');
        if (map['imageUrls'] is List) {
          propertyImageUrls =
              (map['imageUrls'] as List).map((url) => url.toString()).toList();
        }
      } else if (map['photos'] != null) {
        _logger.info(
            'Property.fromMap - Campo photos encontrado con ${(map['photos'] as List).length} imágenes');
        propertyImageUrls = (map['photos'] as List)
            .map<String>((photo) {
              if (photo is Map<String, dynamic>) {
                String url = photo['photo_url']?.toString() ?? '';
                _logger
                    .info('Property.fromMap - URL de imagen encontrada: $url');
                return url;
              }
              return '';
            })
            .where((url) => url.isNotEmpty)
            .toList();
      }

      _logger.info(
          'Property.fromMap - URLs de imágenes extraídas: $propertyImageUrls');

      // Para ownerId, usar broker_id si ownerId no existe
      final String propertyOwnerId =
          map['ownerId']?.toString() ?? map['broker_id']?.toString() ?? '0';

      // Para createdAt, usar createdAt o si no existe, created_at o fecha actual
      DateTime propertyCreatedAt = DateTime.now();
      if (map['createdAt'] != null) {
        try {
          propertyCreatedAt = DateTime.parse(map['createdAt'].toString());
        } catch (e) {
          _logger.warning('Property.fromMap - Error al parsear createdAt: $e');
        }
      } else if (map['created_at'] != null) {
        try {
          propertyCreatedAt = DateTime.parse(map['created_at'].toString());
        } catch (e) {
          _logger.warning('Property.fromMap - Error al parsear created_at: $e');
        }
      }

      // Para likes, usar likes o si no existe, 0
      int propertyLikes = map['likes'] ?? 0;

      List<PropertyPhoto> photosList = [];
      if (map['photos'] != null) {
        photosList = (map['photos'] as List)
            .map((photoJson) => PropertyPhoto.fromJson(photoJson))
            .toList();
      }

      return Property(
        id: propertyId,
        title: propertyTitle,
        description: propertyDescription,
        price: propertyPrice,
        location: propertyLocation,
        bedrooms: propertyBedrooms,
        squareMeters: propertySquareMeters,
        imageUrls:
            propertyImageUrls, // Usar las URLs sin procesar en la versión sincrónica
        ownerId: propertyOwnerId,
        createdAt: propertyCreatedAt,
        comments: map['comments'] != null
            ? (map['comments'] as List)
                .map((comment) => Comment.fromMap(comment))
                .toList()
            : [],
        inquiries: map['inquiries'] != null
            ? (map['inquiries'] as List)
                .map((inquiry) => Inquiry.fromMap(inquiry))
                .toList()
            : [],
        favorite: map['favorite'] == true,
        likes: propertyLikes,
        photos: photosList,
      );
    } catch (e) {
      _logger
          .severe('Property.fromMap - Error al convertir JSON a Property: $e');
      // Devolver una propiedad vacía en caso de error
      return Property(
        id: '0',
        title: 'Error',
        description: 'Error al cargar la propiedad',
        price: 0,
        location: '',
        bedrooms: 0,
        squareMeters: 0,
        imageUrls: [],
        ownerId: '0',
        createdAt: DateTime.now(),
        comments: [],
        inquiries: [],
        likes: 0,
        photos: [],
      );
    }
  }

  // Método asíncrono para procesar imágenes de S3
  static Future<Property> fromMapWithS3(Map<String, dynamic> map) async {
    Property property = Property.fromMap(map);
    try {
      // Procesar las URLs de imágenes con S3Service para obtener URLs accesibles
      List<String> processedImageUrls =
          await _s3Service.processImageUrls(property.imageUrls);
      _logger.info(
          'Property.fromMapWithS3 - URLs de imágenes procesadas por S3Service: $processedImageUrls');

      // Crear una nueva propiedad con las URLs procesadas
      return Property(
        id: property.id,
        title: property.title,
        description: property.description,
        price: property.price,
        location: property.location,
        bedrooms: property.bedrooms,
        squareMeters: property.squareMeters,
        imageUrls: processedImageUrls, // Usar las URLs procesadas
        ownerId: property.ownerId,
        createdAt: property.createdAt,
        comments: property.comments,
        inquiries: property.inquiries,
        favorite: property.favorite,
        likes: property.likes,
        photos: property.photos,
      );
    } catch (e) {
      _logger.severe(
          'Property.fromMapWithS3 - Error al procesar imágenes con S3Service: $e');
      return property; // Devolver la propiedad original si hay un error
    }
  }

  // Crear una copia con los atributos actualizados
  Property copyWith({
    String? id,
    String? title,
    String? description,
    double? price,
    String? location,
    int? bedrooms,
    double? squareMeters,
    List<String>? imageUrls,
    String? ownerId,
    DateTime? createdAt,
    List<Comment>? comments,
    List<Inquiry>? inquiries,
    bool? favorite,
    int? likes,
    List<PropertyPhoto>? photos,
  }) {
    return Property(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      price: price ?? this.price,
      location: location ?? this.location,
      bedrooms: bedrooms ?? this.bedrooms,
      squareMeters: squareMeters ?? this.squareMeters,
      imageUrls: imageUrls ?? this.imageUrls,
      ownerId: ownerId ?? this.ownerId,
      createdAt: createdAt ?? this.createdAt,
      comments: comments ?? this.comments,
      inquiries: inquiries ?? this.inquiries,
      favorite: favorite ?? this.favorite,
      likes: likes ?? this.likes,
      photos: photos ?? this.photos,
    );
  }
}

class PropertyPhoto {
  final int id;
  final String photoUrl;
  final String s3Key;
  final bool isPrimary;
  final String uploadedAt;

  PropertyPhoto({
    required this.id,
    required this.photoUrl,
    required this.s3Key,
    required this.isPrimary,
    required this.uploadedAt,
  });

  factory PropertyPhoto.fromJson(Map<String, dynamic> json) {
    return PropertyPhoto(
      id: json['id'],
      photoUrl: json['photo_url'],
      s3Key: json['s3_key'],
      isPrimary: json['is_primary'] ?? false,
      uploadedAt: json['uploaded_at'] ?? '',
    );
  }
}

extension PropertyPhotoUtils on Property {
  PropertyPhoto? getPrimaryPhoto() {
    if (photos.isNotEmpty) {
      return photos.firstWhere(
        (photo) => photo.isPrimary,
        orElse: () => photos.first,
      );
    }
    return null;
  }
}
