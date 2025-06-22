import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../models/property.dart';
import '../../services/property_service.dart';
import '../../services/auth_service.dart';
import 'property_form_screen.dart';

class PropertyDetailScreen extends StatefulWidget {
  final Property property;

  const PropertyDetailScreen({super.key, required this.property});

  @override
  _PropertyDetailScreenState createState() => _PropertyDetailScreenState();
}

class _PropertyDetailScreenState extends State<PropertyDetailScreen>
    with SingleTickerProviderStateMixin {
  final PropertyService _propertyService = PropertyService();
  final AuthService _authService = AuthService();

  late TabController _tabController;
  Property? _property;
  bool _isLoading = true;
  bool _isLiked = false;
  String? _errorMessage;
  final TextEditingController _commentController = TextEditingController();
  final TextEditingController _inquiryController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _property = widget.property;
    _loadProperty();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _commentController.dispose();
    _inquiryController.dispose();
    super.dispose();
  }

  Future<void> _loadProperty() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final property = await _propertyService.getProperty(widget.property.id);
      final isLiked =
          await _propertyService.isPropertyLiked(widget.property.id);

      if (mounted) {
        setState(() {
          _property = property;
          _isLiked = isLiked;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _toggleLike() async {
    try {
      final isLiked =
          await _propertyService.togglePropertyLike(widget.property.id);
      if (mounted) {
        setState(() {
          _isLiked = isLiked;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(isLiked
                  ? 'Propiedad marcada como favorita'
                  : 'Propiedad eliminada de favoritos')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _deleteProperty() async {
    final confirmed = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Confirmar eliminación'),
            content: const Text(
                '¿Estás seguro de que deseas eliminar esta propiedad? Esta acción no se puede deshacer.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: const Text('Cancelar'),
              ),
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(true),
                child:
                    const Text('Eliminar', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        ) ??
        false;

    if (!confirmed) return;

    try {
      await _propertyService.deleteProperty(widget.property.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Propiedad eliminada con éxito')),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Error al eliminar la propiedad: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _addComment() async {
    if (_commentController.text.trim().isEmpty) return;

    try {
      await _propertyService.addComment(
        widget.property.id,
        _commentController.text.trim(),
      );

      if (mounted) {
        _commentController.clear();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Comentario agregado con éxito')),
        );
        _loadProperty(); // Recargar para mostrar el nuevo comentario
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Error al agregar comentario: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _sendInquiry() async {
    if (_inquiryController.text.trim().isEmpty) return;

    try {
      await _propertyService.addInquiry(
        widget.property.id,
        _inquiryController.text.trim(),
        _authService.userId ?? 'No contact info provided',
      );

      if (mounted) {
        _inquiryController.clear();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Consulta enviada con éxito')),
        );
        _loadProperty(); // Recargar para mostrar la nueva consulta
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al enviar consulta: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Cargando...')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_errorMessage != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Error: $_errorMessage'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadProperty,
                child: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      );
    }

    final property = _property!;
    final isOwner = property.ownerId == _authService.userId;

    return Scaffold(
      appBar: AppBar(
        title: Text(property.title),
        actions: [
          IconButton(
            icon: Icon(_isLiked ? Icons.favorite : Icons.favorite_border),
            color: _isLiked ? Colors.red : null,
            onPressed: _toggleLike,
            tooltip: _isLiked ? 'Quitar de favoritos' : 'Agregar a favoritos',
          ),
          if (isOwner)
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'edit') {
                  Navigator.of(context)
                      .push(
                        MaterialPageRoute(
                          builder: (context) =>
                              PropertyFormScreen(property: property),
                        ),
                      )
                      .then((_) => _loadProperty());
                } else if (value == 'delete') {
                  _deleteProperty();
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit),
                      SizedBox(width: 8),
                      Text('Editar'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Eliminar', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
            ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Detalles'),
            Tab(text: 'Comentarios'),
            Tab(text: 'Consultas'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Pestaña de Detalles
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Imágenes
                property.imageUrls.isNotEmpty
                    ? Stack(
                        children: [
                          SizedBox(
                            height: 250,
                            child: PageView.builder(
                              itemCount: property.imageUrls.length,
                              itemBuilder: (context, index) {
                                return CachedNetworkImage(
                                  imageUrl: property.imageUrls[index],
                                  fit: BoxFit.cover,
                                  // Evitar caché persistente o desactualizado
                                  cacheKey:
                                      '${property.id}_${index}_${DateTime.now().millisecondsSinceEpoch}',
                                  maxWidthDiskCache: 1200,
                                  maxHeightDiskCache: 1200,
                                  // No usar caché para forzar la carga desde la red
                                  useOldImageOnUrlChange: false,
                                  placeholder: (context, url) => const Center(
                                      child: CircularProgressIndicator()),
                                  errorWidget: (context, url, error) =>
                                      const Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.error, color: Colors.red),
                                      SizedBox(height: 8),
                                      Text(
                                        'Error al cargar imagen',
                                        style: TextStyle(fontSize: 12),
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                          // Indicador de cantidad de imágenes
                          if (property.imageUrls.length > 1)
                            Positioned(
                              bottom: 10,
                              right: 10,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.7),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  '${property.imageUrls.length} fotos',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      )
                    : Container(
                        height: 250,
                        color: Colors.grey[200],
                        child: const Center(
                            child: Text('No hay imágenes disponibles')),
                      ),
                const SizedBox(height: 16),

                // Precio y ubicación
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '\$${property.price.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.location_on,
                                  size: 16, color: Colors.grey),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  property.location,
                                  style: TextStyle(color: Colors.grey[700]),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.hotel,
                                  size: 16, color: Colors.blue),
                              const SizedBox(width: 4),
                              Text('${property.bedrooms} dormitorios'),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.square_foot,
                                  size: 16, color: Colors.blue),
                              const SizedBox(width: 4),
                              Text('${property.squareMeters} m²'),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Descripción
                const Text(
                  'Descripción',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(property.description),
                const SizedBox(height: 24),

                // Información del propietario
                const Text(
                  'Propietario',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: Colors.blue.shade100,
                          child: const Icon(Icons.person),
                        ),
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'ID: ${property.ownerId}',
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            Text(isOwner
                                ? 'Eres el dueño de esta propiedad'
                                : 'Contacta para más información'),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Pestaña de Comentarios
          Column(
            children: [
              Expanded(
                child: property.comments.isEmpty
                    ? const Center(child: Text('No hay comentarios todavía'))
                    : ListView.builder(
                        padding: const EdgeInsets.all(8),
                        itemCount: property.comments.length,
                        itemBuilder: (context, index) {
                          final comment = property.comments[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(
                                vertical: 4, horizontal: 8),
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      CircleAvatar(
                                        backgroundColor: Colors.blue.shade50,
                                        radius: 16,
                                        child:
                                            const Icon(Icons.person, size: 18),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Usuario: ${comment.userId.substring(0, Math.min(8, comment.userId.length))}...',
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                      const Spacer(),
                                      Text(
                                        _formatDate(comment.createdAt),
                                        style: TextStyle(
                                            color: Colors.grey[600],
                                            fontSize: 12),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(comment.text),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _commentController,
                        decoration: const InputDecoration(
                          hintText: 'Escribe un comentario...',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 2,
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.send),
                      onPressed: _addComment,
                      tooltip: 'Enviar comentario',
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Pestaña de Consultas
          Column(
            children: [
              Expanded(
                child: property.inquiries.isEmpty
                    ? const Center(child: Text('No hay consultas todavía'))
                    : ListView.builder(
                        padding: const EdgeInsets.all(8),
                        itemCount: property.inquiries.length,
                        itemBuilder: (context, index) {
                          final inquiry = property.inquiries[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(
                                vertical: 4, horizontal: 8),
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      CircleAvatar(
                                        backgroundColor: Colors.green.shade50,
                                        radius: 16,
                                        child: const Icon(Icons.question_answer,
                                            size: 18),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Usuario: ${inquiry.userId.substring(0, Math.min(8, inquiry.userId.length))}...',
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                      const Spacer(),
                                      Text(
                                        _formatDate(inquiry.createdAt),
                                        style: TextStyle(
                                            color: Colors.grey[600],
                                            fontSize: 12),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(inquiry.message),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _inquiryController,
                        decoration: const InputDecoration(
                          hintText: 'Escribe una consulta al propietario...',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 2,
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.send),
                      onPressed: _sendInquiry,
                      tooltip: 'Enviar consulta',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays < 1) {
      if (difference.inHours < 1) {
        return 'Hace ${difference.inMinutes} minutos';
      }
      return 'Hace ${difference.inHours} horas';
    } else if (difference.inDays < 7) {
      return 'Hace ${difference.inDays} días';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}

class Math {
  static int min(int a, int b) {
    return a < b ? a : b;
  }
}
