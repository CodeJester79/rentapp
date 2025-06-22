import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../models/property.dart';
import '../../services/property_service.dart';
import '../../services/auth_service.dart';

class PropertyFormScreen extends StatefulWidget {
  final Property?
      property; // Null para crear nueva propiedad, no-null para editar

  const PropertyFormScreen({super.key, this.property});

  @override
  _PropertyFormScreenState createState() => _PropertyFormScreenState();
}

class _PropertyFormScreenState extends State<PropertyFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final PropertyService _propertyService = PropertyService();
  final AuthService _authService = AuthService();
  final ImagePicker _picker = ImagePicker();

  // Controladores para los campos del formulario
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _locationController = TextEditingController();
  final _bedroomsController = TextEditingController();
  final _squareMetersController = TextEditingController();

  // Imágenes existentes y nuevas imágenes
  List<String> _existingImages = [];
  final List<File> _newImages = [];

  bool _isLoading = false;
  String? _errorMessage;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _isEditing = widget.property != null;

    if (_isEditing) {
      // Prellenar el formulario con los datos de la propiedad existente
      _titleController.text = widget.property!.title;
      _descriptionController.text = widget.property!.description;
      _priceController.text = widget.property!.price.toString();
      _locationController.text = widget.property!.location;
      _bedroomsController.text = widget.property!.bedrooms.toString();
      _squareMetersController.text = widget.property!.squareMeters.toString();
      _existingImages = List.from(widget.property!.imageUrls);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _locationController.dispose();
    _bedroomsController.dispose();
    _squareMetersController.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    try {
      final List<XFile> images = await _picker.pickMultiImage();
      if (images.isNotEmpty) {
        setState(() {
          _newImages.addAll(images.map((xFile) => File(xFile.path)).toList());
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al seleccionar imágenes: $e')),
      );
    }
  }

  void _removeNewImage(int index) {
    setState(() {
      _newImages.removeAt(index);
    });
  }

  void _removeExistingImage(int index) {
    setState(() {
      _existingImages.removeAt(index);
    });
  }

  Future<void> _saveProperty() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Preparar los datos de la propiedad
      final Map<String, dynamic> propertyData = {
        'title': _titleController.text,
        'description': _descriptionController.text,
        'price': double.parse(_priceController.text),
        'location': _locationController.text,
        'bedrooms': int.parse(_bedroomsController.text),
        'squareMeters': double.parse(_squareMetersController.text),
      };

      // Si estamos editando, añadir las imágenes existentes
      if (_isEditing) {
        propertyData['imageUrls'] = _existingImages;
        propertyData['id'] = widget.property!.id;
        propertyData['ownerId'] = widget.property!.ownerId;

        // Actualizar la propiedad
        final Property property = await _propertyService.updateProperty(
            widget.property!.id, propertyData);

        // Subir nuevas imágenes si hay alguna
        if (_newImages.isNotEmpty) {
          await _propertyService.uploadPropertyImages(property.id, _newImages);
        }
      } else {
        // Si es una nueva propiedad, usar el ID del usuario actual
        propertyData['ownerId'] = _authService.userId ?? '';
        propertyData['imageUrls'] = [];

        // Crear la propiedad primero para obtener el ID
        final Property property =
            await _propertyService.createProperty(propertyData);

        // Si hay imágenes, subirlas usando el ID de la propiedad recién creada
        if (_newImages.isNotEmpty) {
          await _propertyService.uploadPropertyImages(property.id, _newImages);
        }
      }

      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  _isEditing ? 'Propiedad actualizada' : 'Propiedad creada')),
        );

        // Volver a la pantalla anterior
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = e.toString();
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $_errorMessage')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Editar Propiedad' : 'Nueva Propiedad'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Título
                    TextFormField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                        labelText: 'Título',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor ingresa un título';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Descripción
                    TextFormField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Descripción',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor ingresa una descripción';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Precio
                    TextFormField(
                      controller: _priceController,
                      decoration: const InputDecoration(
                        labelText: 'Precio (\$)',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor ingresa un precio';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Por favor ingresa un número válido';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Ubicación
                    TextFormField(
                      controller: _locationController,
                      decoration: const InputDecoration(
                        labelText: 'Ubicación',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor ingresa una ubicación';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Fila con dormitorios y metros cuadrados
                    Row(
                      children: [
                        // Número de dormitorios
                        Expanded(
                          child: TextFormField(
                            controller: _bedroomsController,
                            decoration: const InputDecoration(
                              labelText: 'Dormitorios',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Requerido';
                              }
                              if (int.tryParse(value) == null) {
                                return 'Número válido';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        // Metros cuadrados
                        Expanded(
                          child: TextFormField(
                            controller: _squareMetersController,
                            decoration: const InputDecoration(
                              labelText: 'Metros cuadrados',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Requerido';
                              }
                              if (double.tryParse(value) == null) {
                                return 'Número válido';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Sección de imágenes
                    const Text('Imágenes',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),

                    // Imágenes existentes (solo en modo edición)
                    if (_existingImages.isNotEmpty) ...[
                      const Text('Imágenes actuales:'),
                      SizedBox(
                        height: 120,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: _existingImages.length,
                          itemBuilder: (context, index) {
                            return Stack(
                              children: [
                                Container(
                                  margin: const EdgeInsets.only(right: 8),
                                  width: 100,
                                  height: 100,
                                  child: CachedNetworkImage(
                                    imageUrl: _existingImages[index],
                                    fit: BoxFit.cover,
                                    placeholder: (context, url) => const Center(
                                        child: CircularProgressIndicator()),
                                    errorWidget: (context, url, error) =>
                                        const Icon(Icons.error),
                                  ),
                                ),
                                Positioned(
                                  right: 0,
                                  top: 0,
                                  child: IconButton(
                                    icon: const Icon(Icons.remove_circle,
                                        color: Colors.red),
                                    onPressed: () =>
                                        _removeExistingImage(index),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Nuevas imágenes seleccionadas
                    if (_newImages.isNotEmpty) ...[
                      const Text('Nuevas imágenes:'),
                      SizedBox(
                        height: 120,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: _newImages.length,
                          itemBuilder: (context, index) {
                            return Stack(
                              children: [
                                Container(
                                  margin: const EdgeInsets.only(right: 8),
                                  width: 100,
                                  height: 100,
                                  child: Image.file(
                                    _newImages[index],
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                Positioned(
                                  right: 0,
                                  top: 0,
                                  child: IconButton(
                                    icon: const Icon(Icons.remove_circle,
                                        color: Colors.red),
                                    onPressed: () => _removeNewImage(index),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Botón para seleccionar imágenes
                    ElevatedButton.icon(
                      onPressed: _pickImages,
                      icon: const Icon(Icons.add_photo_alternate),
                      label: const Text('Agregar imágenes'),
                    ),
                    const SizedBox(height: 32),

                    // Botón de guardar
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _saveProperty,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: Text(_isEditing
                            ? 'Actualizar Propiedad'
                            : 'Crear Propiedad'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
