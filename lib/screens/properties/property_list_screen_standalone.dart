import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../models/property.dart';
import '../../services/property_service.dart';
import 'package:logging/logging.dart';
import '../../utils/logger.dart';
import '../../services/like_service.dart';
import 'property_form_screen.dart';
import 'property_detail_screen.dart';

/// Versión independiente de PropertyListScreen diseñada para ser navegada directamente
/// y garantizar que siempre se carguen las propiedades al inicializarse
class PropertyListScreenStandalone extends StatefulWidget {
  const PropertyListScreenStandalone({super.key});

  @override
  _PropertyListScreenStandaloneState createState() =>
      _PropertyListScreenStandaloneState();
}

class _PropertyListScreenStandaloneState
    extends State<PropertyListScreenStandalone> {
  final PropertyService _propertyService = PropertyService();
  final Logger _logger = AppLogger.getLogger('PropertyListScreenStandalone');

  List<Property> _properties = [];
  bool _isLoading = true;
  bool _isLocalData = false;
  String? _errorMessage;
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'All';

  final List<String> _categories = ['All', 'House', 'Apartment', 'Villa'];

  @override
  void initState() {
    super.initState();
    _logger.info('PropertyListScreenStandalone - initState() llamado');
    _loadProperties();
  }

  Future<void> _loadProperties() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _isLocalData = false;
    });

    try {
      // Intentar cargar propiedades del servidor
      _logger.info(
          'PropertyListScreenStandalone - Cargando propiedades del servidor...');
      final properties = await _propertyService.getAllProperties();
      _logger.info(
          'PropertyListScreenStandalone - Propiedades recibidas: ${properties.length}');

      // Imprimir detalles de cada propiedad para debugging
      for (var prop in properties) {
        _logger.info(
            'PropertyListScreenStandalone - Propiedad: ID=${prop.id}, Título=${prop.title}, Precio=${prop.price}');
      }

      if (mounted) {
        setState(() {
          _properties = properties;
          _isLoading = false;
          _logger.info(
              'PropertyListScreenStandalone - Estado actualizado, propiedades en _properties: ${_properties.length}');
        });
      }
    } catch (e) {
      _logger.warning(
          'PropertyListScreenStandalone - Error al cargar propiedades del servidor: $e');
      // Si falla, intentar cargar propiedades locales
      try {
        _logger.info(
            'PropertyListScreenStandalone - Intentando cargar propiedades locales...');
        // Como no existe getProperties, simplemente mostramos el error
        _logger.warning(
            'PropertyListScreenStandalone - No hay implementación de carga local');

        if (mounted) {
          setState(() {
            _errorMessage = 'No se pudieron cargar las propiedades';
            _isLoading = false;
            _logger.warning(
                'PropertyListScreenStandalone - Estado actualizado con error: $_errorMessage');
          });
        }
      } catch (localError) {
        _logger.severe(
            'PropertyListScreenStandalone - Error al cargar propiedades locales: $localError');
        if (mounted) {
          setState(() {
            _errorMessage = 'No se pudieron cargar las propiedades';
            _isLoading = false;
            _logger.warning(
                'PropertyListScreenStandalone - Estado actualizado con error: $_errorMessage');
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Propiedades'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadProperties,
            tooltip: 'Recargar propiedades',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _errorMessage!,
                        style: const TextStyle(color: Colors.red),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadProperties,
                        child: const Text('Reintentar'),
                      ),
                    ],
                  ),
                )
              : _properties.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('No hay propiedades disponibles'),
                          if (_isLocalData) ...[
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: _loadProperties,
                              child:
                                  const Text('Reintentar conexión al servidor'),
                            ),
                          ],
                        ],
                      ),
                    )
                  : Column(
                      children: [
                        if (_isLocalData)
                          Container(
                            width: double.infinity,
                            color: Colors.amber[100],
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              'Mostrando datos almacenados localmente. Última actualización: ${DateTime.now().toString()}',
                              style: const TextStyle(fontSize: 12),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        // Barra de búsqueda
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: TextField(
                              controller: _searchController,
                              decoration: InputDecoration(
                                hintText: 'Search House, Apartment, etc',
                                prefixIcon: const Icon(Icons.search),
                                suffixIcon: IconButton(
                                  icon: const Icon(Icons.mic),
                                  onPressed: () {},
                                ),
                                border: InputBorder.none,
                                contentPadding:
                                    const EdgeInsets.symmetric(vertical: 12),
                              ),
                            ),
                          ),
                        ),

                        // Categorías
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: SizedBox(
                            height: 40,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: _categories.length,
                              itemBuilder: (context, index) {
                                final category = _categories[index];
                                final isSelected =
                                    category == _selectedCategory;

                                return GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _selectedCategory = category;
                                    });
                                  },
                                  child: Container(
                                    margin: const EdgeInsets.only(right: 12),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 20),
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? const Color(0xFF4F6CAD)
                                          : Colors.white,
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: isSelected
                                            ? Colors.transparent
                                            : Colors.grey[300]!,
                                      ),
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(
                                      category,
                                      style: TextStyle(
                                        color: isSelected
                                            ? Colors.white
                                            : Colors.black,
                                        fontWeight: isSelected
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        Expanded(
                          child: RefreshIndicator(
                            onRefresh: _loadProperties,
                            child: ListView.builder(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16.0),
                              itemCount: _properties.length,
                              itemBuilder: (context, index) {
                                final property = _properties[index];
                                return PropertyCard(
                                  property: property,
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            PropertyDetailScreen(
                                                property: property),
                                      ),
                                    );
                                  },
                                );
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const PropertyFormScreen()),
          );

          if (result == true) {
            _loadProperties();
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class PropertyCard extends StatefulWidget {
  final Property property;
  final VoidCallback onTap;

  const PropertyCard({
    super.key,
    required this.property,
    required this.onTap,
  });

  @override
  _PropertyCardState createState() => _PropertyCardState();
}

class _PropertyCardState extends State<PropertyCard> {
  final LikeService _likeService = LikeService();
  final Logger _logger = AppLogger.getLogger('PropertyCard');
  bool _isLiked = false;
  bool _isLiking = false;

  Future<void> _toggleLike() async {
    if (_isLiking) return; // Evitar doble tap

    setState(() {
      _isLiking = true;
    });

    try {
      final success = await _likeService.likeProperty(widget.property.id);
      if (success) {
        setState(() {
          _isLiked = !_isLiked;
          // Si le damos like, incrementamos el contador
          if (_isLiked) {
            widget.property.likes++;
          } else {
            // Si quitamos el like, decrementamos (pero nunca por debajo de 0)
            widget.property.likes =
                widget.property.likes > 0 ? widget.property.likes - 1 : 0;
          }
        });
      }
    } catch (e) {
      _logger.severe('Error al procesar like: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLiking = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      clipBehavior: Clip.antiAlias,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Imagen de la propiedad
          GestureDetector(
            onTap: widget.onTap,
            child: Stack(
              children: [
                AspectRatio(
                  aspectRatio: 16 / 9,
                  child: widget.property.imageUrls.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: widget.property.imageUrls[0],
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            color: Colors.grey[200],
                            child: const Center(
                                child: CircularProgressIndicator()),
                          ),
                          errorWidget: (context, url, error) => Container(
                            color: Colors.grey[200],
                            child: const Icon(Icons.home, size: 50),
                          ),
                        )
                      : Container(
                          color: Colors.grey[200],
                          child: const Icon(Icons.home, size: 50),
                        ),
                ),
                // Botón de favorito en la esquina superior derecha
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: InkWell(
                      onTap: _toggleLike,
                      child: Icon(
                        _isLiked ? Icons.favorite : Icons.favorite_border,
                        color: _isLiked ? Colors.red : Colors.grey,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Información de la propiedad
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Título y calificación
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        widget.property.title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 16),
                        Text(
                            ' ${widget.property.likes > 0 ? (4.0 + (widget.property.likes / 10)).toStringAsFixed(1) : "4.0"}'),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                // Ubicación
                Row(
                  children: [
                    const Icon(Icons.location_on, color: Colors.grey, size: 16),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        widget.property.location,
                        style: const TextStyle(color: Colors.grey),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Precio y botón de visita
                Row(
                  children: [
                    Text(
                      '€ ${widget.property.price}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF4F6CAD),
                      ),
                    ),
                    const Text('/month',
                        style: TextStyle(color: Colors.grey, fontSize: 12)),
                    const Spacer(),
                    InkWell(
                      onTap: widget.onTap,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF4F6CAD),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'Visit',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
