import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../widgets/navigation/custom_drawer.dart';
import '../widgets/navigation/custom_bottom_navigation.dart';
import '../services/auth_service.dart';
import 'home/modern_home_page.dart';
import 'properties/property_list_screen.dart';
import '../widgets/common/empty_state_widget.dart';

/// Integration class that wraps the existing HomePage with modern UI components
/// This allows for gradual migration without breaking existing functionality
class ModernHomeIntegration extends StatefulWidget {
  final bool isAdmin;
  final Function? refreshPropertiesCallback;

  const ModernHomeIntegration({
    super.key,
    this.isAdmin = false,
    this.refreshPropertiesCallback,
  });

  @override
  State<ModernHomeIntegration> createState() => _ModernHomeIntegrationState();
}

class _ModernHomeIntegrationState extends State<ModernHomeIntegration> {
  int _currentIndex = 0;
  final AuthService _authService = AuthService();

  // Mock user data - in real app, this would come from AuthService
  final String _userRole = 'customer'; // or 'broker', 'admin'
  final String _userName = 'John Doe';
  final String _userEmail = 'john.doe@example.com';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundSecondary,
      drawer: CustomDrawer(
        userRole: _userRole,
        userName: _userName,
        userEmail: _userEmail,
        onSignOut: _handleSignOut,
      ),
      body: _buildCurrentScreen(),
      bottomNavigationBar: CustomNavigationBar(
        currentIndex: _currentIndex,
        onDestinationSelected: _onDestinationSelected,
        userRole: _userRole,
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  Widget _buildCurrentScreen() {
    switch (_currentIndex) {
      case 0:
        return const ModernHomePage();
      case 1:
        return const PropertyListScreen();
      case 2:
        return const _FavoritesScreen();
      case 3:
        return _userRole == 'admin' || _userRole == 'broker'
            ? const _DashboardScreen()
            : const _ProfileScreen();
      default:
        return const ModernHomePage();
    }
  }

  Widget? _buildFloatingActionButton() {
    // Show FAB only on Properties screen for brokers/admins
    if (_currentIndex == 1 && (_userRole == 'admin' || _userRole == 'broker')) {
      return FloatingActionButton.extended(
        onPressed: _handleAddProperty,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_home_outlined),
        label: const Text(
          'Add Property',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      );
    }
    return null;
  }

  void _onDestinationSelected(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void _handleAddProperty() {
    // TODO: Navigate to Add Property screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Add Property functionality will be implemented'),
        backgroundColor: AppColors.info,
      ),
    );
  }

  Future<void> _handleSignOut() async {
    try {
      await _authService.signOut();
      if (mounted) {
        // Navigate back to sign-in screen
        Navigator.of(context).pushNamedAndRemoveUntil(
          '/',
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error signing out: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }
}

// Placeholder screens with modern design
class _FavoritesScreen extends StatelessWidget {
  const _FavoritesScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorites'),
        backgroundColor: AppColors.surface,
        elevation: 0,
        scrolledUnderElevation: 1,
      ),
      body: const NoFavoritesWidget(
        // onExploreProperties: () {
        //   // TODO: Navigate to properties tab
        // },
      ),
    );
  }
}

class _ProfileScreen extends StatelessWidget {
  const _ProfileScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: AppColors.surface,
        elevation: 0,
        scrolledUnderElevation: 1,
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 48,
              backgroundColor: AppColors.primary,
              child: Icon(
                Icons.person,
                size: 48,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 24),
            Text(
              'John Doe',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: AppColors.onBackground,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'john.doe@example.com',
              style: TextStyle(
                fontSize: 16,
                color: AppColors.neutral600,
              ),
            ),
            SizedBox(height: 24),
            Text(
              'Customer',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DashboardScreen extends StatelessWidget {
  const _DashboardScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        backgroundColor: AppColors.surface,
        elevation: 0,
        scrolledUnderElevation: 1,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Stats Cards
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    context,
                    'Properties',
                    '24',
                    Icons.home_outlined,
                    AppColors.primary,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatCard(
                    context,
                    'Inquiries',
                    '12',
                    Icons.question_answer_outlined,
                    AppColors.secondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    context,
                    'Views',
                    '1.2k',
                    Icons.visibility_outlined,
                    AppColors.accent,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatCard(
                    context,
                    'Revenue',
                    '\$24k',
                    Icons.attach_money_outlined,
                    AppColors.success,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            // Quick Actions
            Text(
              'Quick Actions',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 16),
            // TODO: Add quick action buttons
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(
                icon,
                color: color,
                size: 24,
              ),
              Text(
                value,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: color,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.neutral600,
                ),
          ),
        ],
      ),
    );
  }
}