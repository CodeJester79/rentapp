import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../models/property.dart';
import '../../services/property_service.dart';
import '../../services/local_storage_service.dart';
import 'package:logging/logging.dart';
import '../../utils/logger.dart';
import 'property_form_screen.dart';
import 'property_detail_screen.dart';

// Eliminamos el callback global que intentamos implementar antes

class PropertyListScreen extends StatefulWidget {
  const PropertyListScreen({super.key});

  @override
  _PropertyListScreenState createState() => _PropertyListScreenState();
}

class _PropertyListScreenState extends State<PropertyListScreen>
    with AutomaticKeepAliveClientMixin {
  final PropertyService _propertyService = PropertyService();
  final LocalStorageService _localStorageService = LocalStorageService();
  final Logger _logger = AppLogger.getLogger('PropertyListScreen');

  List<Property> _properties = [];
  bool _isLoading = true;
  bool _isLocalData = false;
  String? _errorMessage;

  @override
  bool get wantKeepAlive => false; // Forzar reconstrucción del widget

  @override
  void initState() {
    super.initState();
    _logger.info('PropertyListScreen - initState() llamado');
    _loadProperties();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _logger.info('PropertyListScreen - didChangeDependencies() llamado');
    _loadProperties();
  }

  @override
  void didUpdateWidget(PropertyListScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    _logger.info('PropertyListScreen - didUpdateWidget() llamado');
  }

  Future<void> _loadProperties() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _isLocalData = false;
    });

    try {
      // Intentar cargar propiedades del servidor, forzando la actualización
      _logger.info(
          'Cargando propiedades del servidor (forzando actualización)...');
      final properties =
          await _propertyService.getAllProperties(forceRefresh: true);
      _logger.info(
          'Propiedades recibidas en PropertyListScreen: ${properties.length}');

      // Imprimir detalles de cada propiedad para debugging
      for (var prop in properties) {
        _logger.info(
            'Propiedad en lista: ID=${prop.id}, Título=${prop.title}, Precio=${prop.price}, Imágenes=${prop.imageUrls}');
      }

      if (mounted) {
        setState(() {
          _properties = properties;
          _isLoading = false;
          _logger.info(
              'Estado actualizado, propiedades en _properties: ${_properties.length}');
        });
      }
    } catch (e) {
      _logger.warning('Error al cargar propiedades del servidor: $e');
      // Si falla, intentar cargar propiedades locales
      try {
        _logger.info('Cargando propiedades locales...');
        final localProperties = await _localStorageService.getLocalProperties();
        if (mounted) {
          setState(() {
            _properties = localProperties;
            _isLoading = false;
            _isLocalData = true;
            _errorMessage =
                'Error de conexión al servidor. Mostrando datos locales.';
          });
        }
      } catch (localError) {
        _logger.severe('Error al cargar propiedades locales: $localError');
        if (mounted) {
          setState(() {
            _errorMessage =
                'No se pudieron cargar las propiedades. Por favor, intente más tarde.';
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Llamar a build de AutomaticKeepAliveClientMixin
    // Log para depuración: confirmar que tenemos propiedades al construir la UI
    _logger.info('build() - Número de propiedades: ${_properties.length}');
    if (_properties.isNotEmpty) {
      _logger.info(
          'Primera propiedad: ID=${_properties[0].id}, Título=${_properties[0].title}');
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Propiedades'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadProperties,
            tooltip: 'Actualizar',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null && _properties.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline,
                          size: 48, color: Colors.red),
                      const SizedBox(height: 16),
                      Text(
                        _errorMessage!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: _loadProperties,
                        child: const Text('Reintentar'),
                      ),
                    ],
                  ),
                )
              : Column(
                  children: [
                    // Mostrar banner cuando se están usando datos locales
                    if (_isLocalData)
                      Container(
                        width: double.infinity,
                        color: Colors.amber.shade100,
                        padding: const EdgeInsets.symmetric(
                            vertical: 8, horizontal: 16),
                        child: Row(
                          children: [
                            const Icon(Icons.info_outline, color: Colors.amber),
                            const SizedBox(width: 8),
                            const Expanded(
                              child: Text(
                                'Mostrando datos guardados localmente. Sin conexión al servidor.',
                                style: TextStyle(fontSize: 12),
                              ),
                            ),
                            TextButton(
                              onPressed: _loadProperties,
                              child: const Text('Reintentar'),
                            ),
                          ],
                        ),
                      ),
                    // Si hay un mensaje de error pero tenemos propiedades locales
                    if (_errorMessage != null &&
                        _properties.isNotEmpty &&
                        !_isLocalData)
                      Container(
                        width: double.infinity,
                        color: Colors.orange.shade100,
                        padding: const EdgeInsets.all(8),
                        child:
                            Text(_errorMessage!, textAlign: TextAlign.center),
                      ),
                    // Lista de propiedades
                    Expanded(
                      child: RefreshIndicator(
                        onRefresh: _loadProperties,
                        child: _properties.isEmpty
                            ? const Center(
                                child: Text('No hay propiedades disponibles'))
                            : GridView.builder(
                                padding: const EdgeInsets.all(16),
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  childAspectRatio: 0.75,
                                  crossAxisSpacing: 16,
                                  mainAxisSpacing: 16,
                                ),
                                itemCount: _properties.length,
                                itemBuilder: (context, index) {
                                  final property = _properties[index];
                                  return PropertyCard(
                                    property: property,
                                    onTap: () {
                                      Navigator.of(context)
                                          .push(
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  PropertyDetailScreen(
                                                      property: property),
                                            ),
                                          )
                                          .then((_) => _loadProperties());
                                    },
                                  );
                                },
                              ),
                      ),
                    ),
                  ],
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context)
              .push(
                MaterialPageRoute(
                  builder: (context) => const PropertyFormScreen(),
                ),
              )
              .then((_) => _loadProperties());
        },
        tooltip: 'Agregar nueva propiedad',
        child: const Icon(Icons.add),
      ),
    );
  }
}

class PropertyCard extends StatelessWidget {
  final Property property;
  final VoidCallback onTap;

  const PropertyCard({
    super.key,
    required this.property,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Imagen de la propiedad
            Expanded(
              child: property.imageUrls.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: property.imageUrls.first,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      // Evitar cachu00e9 persistente o desactualizado
                      cacheKey:
                          '${property.id}_${DateTime.now().millisecondsSinceEpoch}',
                      maxWidthDiskCache: 800,
                      maxHeightDiskCache: 800,
                      // No usar cachu00e9 para forzar la carga desde la red
                      useOldImageOnUrlChange: false,
                      // Mostrar placeholder mientras carga
                      placeholder: (context, url) => Container(
                        color: Colors.grey[200],
                        child: const Center(
                          child: CircularProgressIndicator(),
                        ),
                      ),
                      // Manejar errores
                      errorWidget: (context, url, error) => Container(
                        color: Colors.grey[200],
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.error, color: Colors.red),
                            const SizedBox(height: 8),
                            Text(
                              'Error: $error',
                              style: const TextStyle(fontSize: 10),
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    )
                  : Container(
                      color: Colors.grey[200],
                      child: const Center(
                        child: Icon(Icons.home, size: 50, color: Colors.grey),
                      ),
                    ),
            ),
            // Información de la propiedad
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    property.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '\$${property.price.toStringAsFixed(2)}',
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    property.location,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.hotel, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(
                        '${property.bedrooms}',
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                      const SizedBox(width: 8),
                      Icon(Icons.square_foot,
                          size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(
                        '${property.squareMeters} m²',
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
