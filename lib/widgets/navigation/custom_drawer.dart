import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/navigation/app_routes.dart';

class CustomDrawer extends StatelessWidget {
  final String? userRole;
  final String? userName;
  final String? userEmail;
  final VoidCallback? onSignOut;

  const CustomDrawer({
    super.key,
    this.userRole,
    this.userName,
    this.userEmail,
    this.onSignOut,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppColors.surface,
      child: Column(
        children: [
          // Header with user info
          _buildDrawerHeader(context),
          // Navigation items
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                ..._buildMainNavigation(context),
                if (_isAdmin || _isBroker) ...[
                  const Divider(height: 1),
                  ..._buildPropertyManagement(context),
                ],
                if (_isAdmin) ...[
                  const Divider(height: 1),
                  ..._buildUserManagement(context),
                ],
                const Divider(height: 1),
                ..._buildSettingsSection(context),
              ],
            ),
          ),
          // Sign out button
          _buildSignOutSection(context),
        ],
      ),
    );
  }

  bool get _isAdmin => userRole == AppConstants.roleAdmin;
  bool get _isBroker => userRole == AppConstants.roleBroker;
  bool get _isCustomer => userRole == AppConstants.roleCustomer;

  Widget _buildDrawerHeader(BuildContext context) {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary,
            AppColors.primaryDark,
          ],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // App Logo/Name
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.home_rounded,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    AppConstants.appName,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ],
              ),
              const Spacer(),
              // User Info
              if (userName != null) ...[
                Text(
                  userName!,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 4),
              ],
              if (userEmail != null) ...[
                Text(
                  userEmail!,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withOpacity(0.9),
                      ),
                ),
                const SizedBox(height: 8),
              ],
              // Role Badge
              if (userRole != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    _getRoleDisplayName(userRole!),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildMainNavigation(BuildContext context) {
    return [
      _buildSectionHeader('Navigation'),
      _buildDrawerItem(
        context,
        icon: Icons.home_outlined,
        title: 'Home',
        route: AppRoutes.home,
      ),
      _buildDrawerItem(
        context,
        icon: Icons.apartment_outlined,
        title: 'Properties',
        route: AppRoutes.properties,
      ),
      _buildDrawerItem(
        context,
        icon: Icons.favorite_outline,
        title: 'Favorites',
        route: AppRoutes.favorites,
      ),
      _buildDrawerItem(
        context,
        icon: Icons.search,
        title: 'Search',
        route: AppRoutes.search,
      ),
      if (!_isCustomer)
        _buildDrawerItem(
          context,
          icon: Icons.notifications_outlined,
          title: 'Activity',
          route: AppRoutes.activity,
        ),
    ];
  }

  List<Widget> _buildPropertyManagement(BuildContext context) {
    return [
      _buildSectionHeader('Property Management'),
      _buildDrawerItem(
        context,
        icon: Icons.add_home_outlined,
        title: 'Add Property',
        route: AppRoutes.addProperty,
      ),
      _buildDrawerItem(
        context,
        icon: Icons.view_list_outlined,
        title: 'My Properties',
        route: AppRoutes.properties,
        // TODO: Add query parameter to filter by user's properties
      ),
      _buildDrawerItem(
        context,
        icon: Icons.question_answer_outlined,
        title: 'Inquiries',
        route: AppRoutes.inquiries,
      ),
      _buildDrawerItem(
        context,
        icon: Icons.photo_library_outlined,
        title: 'Photo Gallery',
        route: AppRoutes.propertyPhotos,
      ),
    ];
  }

  List<Widget> _buildUserManagement(BuildContext context) {
    return [
      _buildSectionHeader('User Management'),
      _buildDrawerItem(
        context,
        icon: Icons.people_outlined,
        title: 'All Users',
        route: AppRoutes.userList,
      ),
      _buildDrawerItem(
        context,
        icon: Icons.person_add_outlined,
        title: 'Create User',
        route: AppRoutes.createUser,
      ),
      _buildDrawerItem(
        context,
        icon: Icons.real_estate_agent_outlined,
        title: 'Agents',
        route: AppRoutes.agentList,
      ),
    ];
  }

  List<Widget> _buildSettingsSection(BuildContext context) {
    return [
      _buildSectionHeader('Settings & Support'),
      _buildDrawerItem(
        context,
        icon: Icons.settings_outlined,
        title: 'Settings',
        route: AppRoutes.settings,
      ),
      _buildDrawerItem(
        context,
        icon: Icons.account_circle_outlined,
        title: 'Account',
        route: AppRoutes.accountSettings,
      ),
      _buildDrawerItem(
        context,
        icon: Icons.privacy_tip_outlined,
        title: 'Privacy',
        route: AppRoutes.privacySettings,
      ),
      _buildDrawerItem(
        context,
        icon: Icons.help_outline,
        title: 'Help & Support',
        route: AppRoutes.helpSupport,
      ),
    ];
  }

  Widget _buildSignOutSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: AppColors.divider,
            width: 1,
          ),
        ),
      ),
      child: SizedBox(
        width: double.infinity,
        child: OutlinedButton.icon(
          onPressed: onSignOut,
          icon: const Icon(Icons.logout, color: AppColors.error),
          label: const Text(
            'Sign Out',
            style: TextStyle(color: AppColors.error),
          ),
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: AppColors.error),
            padding: const EdgeInsets.symmetric(vertical: 12),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: AppColors.neutral500,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildDrawerItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String route,
    int? badgeCount,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: AppColors.neutral600,
        size: 22,
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: AppColors.onSurface,
        ),
      ),
      trailing: badgeCount != null && badgeCount > 0
          ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.error,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                badgeCount.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            )
          : const Icon(
              Icons.chevron_right,
              color: AppColors.neutral400,
              size: 20,
            ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      onTap: () {
        Navigator.of(context).pop(); // Close drawer
        Navigator.of(context).pushNamed(route);
      },
    );
  }

  String _getRoleDisplayName(String role) {
    switch (role) {
      case AppConstants.roleAdmin:
        return 'Administrator';
      case AppConstants.roleBroker:
        return 'Broker';
      case AppConstants.roleCustomer:
        return 'Customer';
      default:
        return 'User';
    }
  }
}