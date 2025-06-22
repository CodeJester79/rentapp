import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/property_service.dart';
import '../models/property.dart';
import 'properties/property_form_screen.dart';
import 'package:logging/logging.dart';
import '../utils/logger.dart';
import 'properties/property_list_screen_standalone.dart'; // Importación de la versión standalone
import 'package:cached_network_image/cached_network_image.dart';

class HomePage extends StatefulWidget {
  final bool isAdmin;
  final Function? refreshPropertiesCallback;

  const HomePage({
    super.key,
    this.isAdmin = false,
    this.refreshPropertiesCallback,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  final AuthService _authService = AuthService();
  final PropertyService _propertyService = PropertyService();
  bool _isLoading = true;
  final Logger _logger = AppLogger.getLogger('HomePage');
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'All';
  List<Property> _properties = [];
  bool _loadingProperties = false;

  final List<String> _categories = ['All', 'House', 'Apartment', 'Condo'];

  @override
  void initState() {
    super.initState();
    // Verificar el estado de la autenticación al iniciar
    _checkAuthStatus();
    // Cargar propiedades
    _loadProperties();
  }

  Future<void> _loadProperties() async {
    if (_loadingProperties) return;

    setState(() {
      _loadingProperties = true;
    });

    try {
      final properties = await _propertyService.getAllProperties();
      if (mounted) {
        setState(() {
          _properties = properties;
          _loadingProperties = false;
        });
      }
    } catch (e) {
      _logger.severe('Error al cargar propiedades: $e');
      if (mounted) {
        setState(() {
          _loadingProperties = false;
        });
      }
    }
  }

  Future<void> _checkAuthStatus() async {
    try {
      // Comprobar si tenemos token almacenado
      final hasToken = await _authService.tryAutoLogin();
      _logger.info('Estado de autenticación verificado: $hasToken');

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }

      if (!hasToken && mounted) {
        _logger.info('No hay sesión activa, redirigiendo a login');
        _navigateToLogin();
      }
    } catch (e) {
      _logger.severe('Error al verificar estado de autenticación: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _navigateToLogin() {
    Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    // Recargar propiedades cuando se navega a la pestaña de propiedades
    if (index == 0) {
      _logger.info('Navegando a pestaña de propiedades - Recargando datos');
      _loadProperties();
      // Llamar directamente al callback global para recargar propiedades
      if (widget.refreshPropertiesCallback != null) {
        _logger.info('Ejecutando callback para recargar propiedades');
        widget.refreshPropertiesCallback!();
      }
    }
  }

  Future<void> _logout(BuildContext context) async {
    try {
      await _authService.signOut();
      if (mounted) {
        _navigateToLogin();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cerrar sesión: ${e.toString()}')),
        );
      }
    }
  }

  Widget _getPage(int index) {
    _logger.info('_getPage llamado con índice: $index');
    switch (index) {
      case 0:
        return _buildHomeContent();
      case 1:
        return _buildSettingsContent();
      case 2:
        return _buildProfileContent();
      case 3:
        return _buildFavoritesContent();
      default:
        return _buildHomeContent();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      body: SafeArea(
        child: _getPage(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Favorites',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
      floatingActionButton: _selectedIndex == 0
          ? FloatingActionButton(
              onPressed: () {
                Navigator.of(context)
                    .push(
                      MaterialPageRoute(
                        builder: (context) => const PropertyFormScreen(),
                      ),
                    )
                    .then((_) =>
                        _loadProperties()); // Refrescar después de volver
              },
              tooltip: 'Agregar nueva propiedad',
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  // Widget para la sección de inicio
  Widget _buildHomeContent() {
    // Obtener el nombre de usuario o un valor predeterminado
    String userName = _authService.currentUser?.username ??
        _authService.currentUser?.email ??
        'User';

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Encabezado con saludo y perfil
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Text(
                        'Good Morning ',
                        style: TextStyle(fontSize: 16),
                      ),
                      Icon(Icons.wb_sunny, color: Colors.amber, size: 16),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Hey, $userName!',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF4F6CAD),
                    ),
                  ),
                  const Text(
                    'Let\'s start exploring',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
              Stack(
                alignment: Alignment.topRight,
                children: [
                  const CircleAvatar(
                    radius: 24,
                    backgroundImage: NetworkImage(
                      'https://randomuser.me/api/portraits/men/1.jpg',
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.notifications,
                      color: Color(0xFF4F6CAD),
                      size: 18,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Barra de búsqueda
          Container(
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
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Categorías
          SizedBox(
            height: 40,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final category = _categories[index];
                final isSelected = category == _selectedCategory;

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedCategory = category;
                    });
                  },
                  child: Container(
                    margin: const EdgeInsets.only(right: 12),
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(
                      color:
                          isSelected ? const Color(0xFF4F6CAD) : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color:
                            isSelected ? Colors.transparent : Colors.grey[300]!,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      category,
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.black,
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 20),

          // Carrusel de propiedades recientes
          _loadingProperties
              ? const Center(child: CircularProgressIndicator(strokeWidth: 2))
              : _properties.isEmpty
                  ? Container(
                      height: 150,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(16),
                      ),
                      alignment: Alignment.center,
                      child: const Text('No hay propiedades disponibles'),
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Latest Properties',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          height: 150,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount:
                                _properties.length > 5 ? 5 : _properties.length,
                            itemBuilder: (context, index) {
                              final property = _properties[index];
                              return _buildPropertyCardHorizontal(property);
                            },
                          ),
                        ),
                      ],
                    ),

          const SizedBox(height: 20),

          // Título de propiedades destacadas
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Featured Estates',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          const PropertyListScreenStandalone(),
                    ),
                  );
                },
                child: const Text('view all'),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Propiedades destacadas
          _loadingProperties
              ? const Center(child: CircularProgressIndicator())
              : _properties.isEmpty
                  ? const Center(child: Text('No hay propiedades disponibles'))
                  : Expanded(
                      child: ListView.builder(
                        itemCount:
                            _properties.length > 3 ? 3 : _properties.length,
                        itemBuilder: (context, index) {
                          final property = _properties[index];
                          return _buildPropertyCard(property);
                        },
                      ),
                    ),
        ],
      ),
    );
  }

  // Widget para tarjeta de propiedad horizontal (carrusel)
  Widget _buildPropertyCardHorizontal(Property property) {
    // Imagen por defecto si no hay fotos disponibles
    String imageUrl =
        'https://images.unsplash.com/photo-1522708323590-d24dbb6b0267';

    // Si la propiedad tiene fotos, usar la primera
    if (property.imageUrls.isNotEmpty) {
      imageUrl = property.imageUrls[0];
    }

    return Container(
      width: 240,
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Imagen de la propiedad
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
            ),
            child: Stack(
              children: [
                CachedNetworkImage(
                  imageUrl: imageUrl,
                  height: 100,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    height: 100,
                    width: double.infinity,
                    color: Colors.grey[300],
                    child: const Center(child: CircularProgressIndicator()),
                  ),
                  errorWidget: (context, url, error) => Container(
                    height: 100,
                    width: double.infinity,
                    color: Colors.grey[300],
                    child: const Icon(Icons.home, size: 40, color: Colors.grey),
                  ),
                ),
                // Precio en overlay
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          Colors.black.withOpacity(0.7),
                          Colors.transparent,
                        ],
                      ),
                    ),
                    child: Text(
                      '\$ ${property.price.toStringAsFixed(0)}/month',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Información de la propiedad
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  property.title,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 12),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.location_on, color: Colors.grey, size: 12),
                    const SizedBox(width: 2),
                    Expanded(
                      child: Text(
                        property.location,
                        style:
                            const TextStyle(color: Colors.grey, fontSize: 10),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
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

  Widget _buildPropertyCard(Property property) {
    // Imagen por defecto si no hay fotos disponibles
    String imageUrl =
        'https://images.unsplash.com/photo-1522708323590-d24dbb6b0267';

    // Si la propiedad tiene fotos, usar la primera
    if (property.imageUrls.isNotEmpty) {
      imageUrl = property.imageUrls[0];
    }

    // Calcular rating (simulado para este ejemplo)
    double rating = 4.5 + (property.id.hashCode % 5) / 10;
    if (rating > 5.0) rating = 5.0;

    return Container(
      height: 100,
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          // Imagen de la propiedad
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: CachedNetworkImage(
              imageUrl: imageUrl,
              width: 100,
              height: 100,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                width: 100,
                height: 100,
                color: Colors.grey[300],
                child: const Center(child: CircularProgressIndicator()),
              ),
              errorWidget: (context, url, error) => Container(
                width: 100,
                height: 100,
                color: Colors.grey[300],
                child: const Icon(Icons.home, size: 40, color: Colors.grey),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Información de la propiedad
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        property.title,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 16),
                        Text(' ${rating.toStringAsFixed(1)}'),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.location_on, color: Colors.grey, size: 14),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        property.location,
                        style:
                            const TextStyle(color: Colors.grey, fontSize: 12),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                      '\$ ${property.price.toStringAsFixed(0)}',
                      style: const TextStyle(
                        color: Color(0xFF4F6CAD),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Text('/month',
                        style: TextStyle(color: Colors.grey, fontSize: 12)),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF4F6CAD),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'Visit',
                        style: TextStyle(color: Colors.white, fontSize: 12),
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

  // Widget para la sección de configuración
  Widget _buildSettingsContent() {
    return ListView(
      children: [
        ListTile(
          leading: const Icon(Icons.person),
          title: const Text('Profile Management'),
          subtitle: const Text('Edit profile, change password'),
          onTap: () {
            // TODO: Navigate to profile management screen
          },
        ),
        ListTile(
          leading: const Icon(Icons.notifications),
          title: const Text('Notification Settings'),
          subtitle: const Text('Email, push notifications'),
          onTap: () {
            // TODO: Navigate to notification settings screen
          },
        ),
        ListTile(
          leading: const Icon(Icons.list),
          title: const Text('Listing Management'),
          subtitle: const Text('Add/Edit/Delete listings'),
          onTap: () {
            // TODO: Navigate to listing management screen
          },
        ),
        ListTile(
          leading: const Icon(Icons.phone),
          title: const Text('Contact Information'),
          subtitle: const Text('Phone number, email'),
          onTap: () {
            // TODO: Navigate to contact information screen
          },
        ),
        ListTile(
          leading: const Icon(Icons.subscriptions),
          title: const Text('Subscription Management'),
          subtitle: const Text('Plan details, billing information'),
          onTap: () {
            // TODO: Navigate to subscription management screen
          },
        ),
        ListTile(
          leading: const Icon(Icons.help),
          title: const Text('Support/Help Center'),
          subtitle: const Text('FAQ, contact support'),
          onTap: () {
            // TODO: Navigate to support/help center screen
          },
        ),
        ListTile(
          leading: const Icon(Icons.description),
          title: const Text('Terms of Service & Privacy Policy'),
          subtitle: const Text('Legal information'),
          onTap: () {
            // TODO: Navigate to terms of service & privacy policy screen
          },
        ),
      ],
    );
  }

  // Widget para la sección de favoritos
  Widget _buildFavoritesContent() {
    return FutureBuilder<List<Property>>(
      future: _propertyService.getLikedProperties(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else {
          final likedProperties = snapshot.data ?? [];
          final lastThreeProperties = likedProperties.length > 3
              ? likedProperties.sublist(likedProperties.length - 3)
              : likedProperties;

          return ListView.builder(
            itemCount: lastThreeProperties.length,
            itemBuilder: (context, index) {
              final property = lastThreeProperties[index];
              return ListTile(
                title: Text(property.title),
                subtitle: Text(property.location),
              );
            },
          );
        }
      },
    );
  }

  // Widget para la sección de perfil
  Widget _buildProfileContent() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('Perfil de Usuario'),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => _logout(context),
            child: const Text('Cerrar Sesión'),
          ),
        ],
      ),
    );
  }
}
