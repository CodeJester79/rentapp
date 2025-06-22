import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/constants/app_constants.dart';
import '../widgets/navigation/custom_drawer.dart';
import '../widgets/navigation/custom_bottom_navigation.dart';
import '../services/auth_service.dart';
import 'home_page.dart';
import 'properties/property_list_screen.dart';

class MainScreen extends StatefulWidget {
  final String? userRole;
  final String? userName;
  final String? userEmail;

  const MainScreen({
    super.key,
    this.userRole,
    this.userName,
    this.userEmail,
  });

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundSecondary,
      drawer: CustomDrawer(
        userRole: widget.userRole,
        userName: widget.userName,
        userEmail: widget.userEmail,
        onSignOut: _handleSignOut,
      ),
      body: _buildCurrentScreen(),
      bottomNavigationBar: CustomNavigationBar(
        currentIndex: _currentIndex,
        onDestinationSelected: _onDestinationSelected,
        userRole: widget.userRole,
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  Widget _buildCurrentScreen() {
    switch (_currentIndex) {
      case 0:
        return const HomePage();
      case 1:
        return const PropertyListScreen();
      case 2:
        return _buildFavoritesScreen();
      case 3:
        return _isAdminOrBroker
            ? _buildDashboardScreen()
            : _buildProfileScreen();
      default:
        return const HomePage();
    }
  }

  Widget? _buildFloatingActionButton() {
    // Show FAB only on Properties screen for brokers/admins
    if (_currentIndex == 1 && _isAdminOrBroker) {
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
        content: Text('Add Property functionality coming soon'),
        backgroundColor: AppColors.info,
      ),
    );
  }

  Future<void> _handleSignOut() async {
    try {
      await _authService.signOut();
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/sign-in');
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

  bool get _isAdminOrBroker =>
      widget.userRole == AppConstants.roleAdmin ||
      widget.userRole == AppConstants.roleBroker;

  Widget _buildFavoritesScreen() {
    return const FavoritesScreen();
  }

  Widget _buildProfileScreen() {
    return const ProfileScreen();
  }

  Widget _buildDashboardScreen() {
    return const DashboardScreen();
  }
}

// Placeholder screens for the new structure
class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorites'),
        backgroundColor: AppColors.surface,
        elevation: 0,
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.favorite_outline,
              size: 64,
              color: AppColors.neutral400,
            ),
            SizedBox(height: 16),
            Text(
              'No favorites yet',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.neutral600,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Properties you like will appear here',
              style: TextStyle(
                color: AppColors.neutral500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: AppColors.surface,
        elevation: 0,
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.person_outline,
              size: 64,
              color: AppColors.neutral400,
            ),
            SizedBox(height: 16),
            Text(
              'Profile Screen',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.neutral600,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'User profile information will be here',
              style: TextStyle(
                color: AppColors.neutral500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        backgroundColor: AppColors.surface,
        elevation: 0,
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.dashboard_outlined,
              size: 64,
              color: AppColors.neutral400,
            ),
            SizedBox(height: 16),
            Text(
              'Dashboard',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.neutral600,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Property management dashboard',
              style: TextStyle(
                color: AppColors.neutral500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}