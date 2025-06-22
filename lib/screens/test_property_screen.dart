import 'package:flutter/material.dart';
import '../models/property.dart';
import '../services/property_service.dart';
import 'package:logging/logging.dart';
import '../utils/logger.dart';

class TestPropertyScreen extends StatefulWidget {
  const TestPropertyScreen({super.key});

  @override
  _TestPropertyScreenState createState() => _TestPropertyScreenState();
}

class _TestPropertyScreenState extends State<TestPropertyScreen> {
  final PropertyService _propertyService = PropertyService();
  final Logger _logger = AppLogger.getLogger('TestPropertyScreen');
  List<Property> _properties = [];
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    // Cargar propiedades automáticamente al iniciar
    _loadProperties();
  }

  Future<void> _loadProperties() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _properties = [];
    });

    try {
      _logger.info('TEST: Cargando propiedades desde el servidor...');
      final properties = await _propertyService.getAllProperties();
      _logger.info('TEST: Propiedades recibidas: ${properties.length}');

      for (var prop in properties) {
        _logger.info(
            'TEST: Propiedad cargada - ID: ${prop.id}, Título: ${prop.title}, Precio: ${prop.price}');
      }

      if (mounted) {
        setState(() {
          _properties = properties;
          _isLoading = false;
        });
      }
    } catch (e) {
      _logger.severe('TEST: Error al cargar propiedades: $e');
      if (mounted) {
        setState(() {
          _errorMessage = 'Error: $e';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Test Propiedades'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: _loadProperties,
              child: const Text('Cargar Propiedades'),
            ),
          ),
          if (_isLoading)
            const Center(child: CircularProgressIndicator())
          else if (_errorMessage != null)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(_errorMessage!,
                  style: const TextStyle(color: Colors.red)),
            )
          else
            Expanded(
              child: _properties.isEmpty
                  ? const Center(child: Text('No hay propiedades'))
                  : ListView.builder(
                      itemCount: _properties.length,
                      itemBuilder: (context, index) {
                        final property = _properties[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          child: ListTile(
                            title: Text(property.title),
                            subtitle: Text(
                              'ID: ${property.id}\n'
                              'Precio: \$${property.price}\n'
                              'Ubicación: ${property.location}\n'
                              'Habitaciones: ${property.bedrooms}\n'
                              'Área: ${property.squareMeters} m²',
                            ),
                            isThreeLine: true,
                          ),
                        );
                      },
                    ),
            ),
        ],
      ),
    );
  }
}
