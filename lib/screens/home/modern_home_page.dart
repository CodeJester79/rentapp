import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/common/custom_card.dart';
import '../../widgets/common/loading_widgets.dart';
import '../../widgets/common/empty_state_widget.dart';
import '../../services/property_service.dart';
import '../../models/property.dart';
import 'package:logging/logging.dart';
import '../../utils/logger.dart';

class ModernHomePage extends StatefulWidget {
  const ModernHomePage({super.key});

  @override
  State<ModernHomePage> createState() => _ModernHomePageState();
}

class _ModernHomePageState extends State<ModernHomePage> {
  final PropertyService _propertyService = PropertyService();
  final Logger _logger = AppLogger.getLogger('ModernHomePage');
  final TextEditingController _searchController = TextEditingController();
  
  List<Property> _featuredProperties = [];
  List<Property> _recentProperties = [];
  bool _isLoading = true;
  bool _hasError = false;
  String _selectedCategory = 'All';
  
  final List<String> _categories = [
    'All',
    'Apartment',
    'House',
    'Studio',
    'Condo'
  ];

  @override
  void initState() {
    super.initState();
    _loadHomeData();
  }

  Future<void> _loadHomeData() async {
    try {
      setState(() {
        _isLoading = true;
        _hasError = false;
      });

      _logger.info('Loading home page data...');
      
      // Load properties
      final properties = await _propertyService.getProperties();
      
      if (mounted) {
        setState(() {
          _featuredProperties = properties.take(5).toList();
          _recentProperties = properties;
          _isLoading = false;
        });
      }
      
      _logger.info('Home data loaded successfully. Properties: ${properties.length}');
    } catch (e) {
      _logger.severe('Error loading home data: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundSecondary,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadHomeData,
          color: AppColors.primary,
          child: _buildBody(),
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: LoadingWidget(
          message: 'Loading your dream properties...',
        ),
      );
    }

    if (_hasError) {
      return NetworkErrorWidget(
        onRetry: _loadHomeData,
      );
    }

    return CustomScrollView(
      slivers: [
        // App Bar
        _buildSliverAppBar(),
        // Search Section
        SliverToBoxAdapter(child: _buildSearchSection()),
        // Categories
        SliverToBoxAdapter(child: _buildCategoriesSection()),
        // Featured Properties
        SliverToBoxAdapter(child: _buildFeaturedSection()),
        // Recent Properties
        SliverToBoxAdapter(child: _buildRecentSection()),
        // Bottom padding
        const SliverToBoxAdapter(
          child: SizedBox(height: 100),
        ),
      ],
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 120,
      floating: false,
      pinned: true,
      backgroundColor: AppColors.surface,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.primary.withOpacity(0.1),
                AppColors.secondary.withOpacity(0.1),
              ],
            ),
          ),
          padding: const EdgeInsets.fromLTRB(16, 60, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Find Your',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: AppColors.neutral700,
                      fontWeight: FontWeight.w400,
                    ),
              ),
              Text(
                'Dream Home',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ],
          ),
        ),
      ),
      leading: Builder(
        builder: (context) => IconButton(
          icon: const Icon(Icons.menu_rounded),
          color: AppColors.primary,
          onPressed: () => Scaffold.of(context).openDrawer(),
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_outlined),
          color: AppColors.primary,
          onPressed: () {
            // TODO: Navigate to notifications
          },
        ),
      ],
    );
  }

  Widget _buildSearchSection() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.neutral200.withOpacity(0.5),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Search for properties...',
            hintStyle: TextStyle(
              color: AppColors.neutral400,
            ),
            prefixIcon: Icon(
              Icons.search,
              color: AppColors.neutral500,
            ),
            suffixIcon: IconButton(
              icon: Icon(
                Icons.tune,
                color: AppColors.primary,
              ),
              onPressed: () {
                // TODO: Open filters
              },
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            filled: true,
            fillColor: AppColors.surface,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
          onSubmitted: (value) {
            // TODO: Implement search
          },
        ),
      ),
    );
  }

  Widget _buildCategoriesSection() {
    return SizedBox(
      height: 60,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final category = _categories[index];
          final isSelected = category == _selectedCategory;
          
          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: FilterChip(
              label: Text(category),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _selectedCategory = category;
                });
                // TODO: Filter properties by category
              },
              backgroundColor: AppColors.surface,
              selectedColor: AppColors.primary,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : AppColors.neutral600,
                fontWeight: FontWeight.w600,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: isSelected ? AppColors.primary : AppColors.neutral300,
                ),
              ),
              elevation: isSelected ? 2 : 0,
            ),
          );
        },
      ),
    );
  }

  Widget _buildFeaturedSection() {
    if (_featuredProperties.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Featured Properties',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.onBackground,
                    ),
              ),
              TextButton(
                onPressed: () {
                  // TODO: Navigate to all properties
                },
                child: const Text('View All'),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 300,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _featuredProperties.length,
            itemBuilder: (context, index) {
              final property = _featuredProperties[index];
              return SizedBox(
                width: 280,
                child: Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: PropertyCard(
                    imageUrl: property.imageUrls.isNotEmpty 
                        ? property.imageUrls.first 
                        : '',
                    title: property.title,
                    price: '\$${property.price.toStringAsFixed(0)}/month',
                    location: property.location,
                    beds: property.bedrooms.toString(),
                    baths: '2', // TODO: Add bathrooms to property model
                    area: '${property.squareMeters.toInt()} sqm',
                    isFavorite: property.favorite,
                    tags: const ['Featured'],
                    onTap: () {
                      // TODO: Navigate to property details
                    },
                    onFavoriteToggle: () {
                      // TODO: Toggle favorite
                    },
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildRecentSection() {
    if (_recentProperties.isEmpty) {
      return NoPropertiesWidget(
        canAddProperty: false, // TODO: Check user role
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
          child: Text(
            'Recent Properties',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.onBackground,
                ),
          ),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _recentProperties.length,
          itemBuilder: (context, index) {
            final property = _recentProperties[index];
            return PropertyCard(
              imageUrl: property.imageUrls.isNotEmpty 
                  ? property.imageUrls.first 
                  : '',
              title: property.title,
              price: '\$${property.price.toStringAsFixed(0)}/month',
              location: property.location,
              beds: property.bedrooms.toString(),
              baths: '2', // TODO: Add bathrooms to property model
              area: '${property.squareMeters.toInt()} sqm',
              isFavorite: property.favorite,
              onTap: () {
                // TODO: Navigate to property details
              },
              onFavoriteToggle: () {
                // TODO: Toggle favorite
              },
            );
          },
        ),
      ],
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}