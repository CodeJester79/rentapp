import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class CustomBottomNavigation extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  final String? userRole;

  const CustomBottomNavigation({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.userRole,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: AppColors.neutral200.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: onTap,
        type: BottomNavigationBarType.fixed,
        backgroundColor: AppColors.surface,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.neutral400,
        selectedLabelStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        items: _getBottomNavItems(),
      ),
    );
  }

  List<BottomNavigationBarItem> _getBottomNavItems() {
    final List<BottomNavigationBarItem> items = [
      const BottomNavigationBarItem(
        icon: Icon(Icons.home_outlined),
        activeIcon: Icon(Icons.home_rounded),
        label: 'Home',
      ),
      const BottomNavigationBarItem(
        icon: Icon(Icons.apartment_outlined),
        activeIcon: Icon(Icons.apartment),
        label: 'Properties',
      ),
      const BottomNavigationBarItem(
        icon: Icon(Icons.favorite_outline),
        activeIcon: Icon(Icons.favorite),
        label: 'Favorites',
      ),
    ];

    // Add different 4th tab based on user role
    if (userRole == 'admin' || userRole == 'broker') {
      items.add(
        const BottomNavigationBarItem(
          icon: Icon(Icons.dashboard_outlined),
          activeIcon: Icon(Icons.dashboard),
          label: 'Dashboard',
        ),
      );
    } else {
      items.add(
        const BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          activeIcon: Icon(Icons.person),
          label: 'Profile',
        ),
      );
    }

    return items;
  }
}

class CustomNavigationBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onDestinationSelected;
  final String? userRole;

  const CustomNavigationBar({
    super.key,
    required this.currentIndex,
    required this.onDestinationSelected,
    this.userRole,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: AppColors.neutral200.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: onDestinationSelected,
        backgroundColor: AppColors.surface,
        indicatorColor: AppColors.primary.withOpacity(0.12),
        destinations: _getNavigationDestinations(),
      ),
    );
  }

  List<NavigationDestination> _getNavigationDestinations() {
    final List<NavigationDestination> destinations = [
      const NavigationDestination(
        icon: Icon(Icons.home_outlined),
        selectedIcon: Icon(Icons.home_rounded),
        label: 'Home',
      ),
      const NavigationDestination(
        icon: Icon(Icons.apartment_outlined),
        selectedIcon: Icon(Icons.apartment),
        label: 'Properties',
      ),
      const NavigationDestination(
        icon: Icon(Icons.favorite_outline),
        selectedIcon: Icon(Icons.favorite),
        label: 'Favorites',
      ),
    ];

    // Add different 4th tab based on user role
    if (userRole == 'admin' || userRole == 'broker') {
      destinations.add(
        const NavigationDestination(
          icon: Icon(Icons.dashboard_outlined),
          selectedIcon: Icon(Icons.dashboard),
          label: 'Dashboard',
        ),
      );
    } else {
      destinations.add(
        const NavigationDestination(
          icon: Icon(Icons.person_outline),
          selectedIcon: Icon(Icons.person),
          label: 'Profile',
        ),
      );
    }

    return destinations;
  }
}

// Custom tab indicator for enhanced visual appeal
class CustomTabIndicator extends Decoration {
  final Color color;
  final double radius;
  final double height;

  const CustomTabIndicator({
    required this.color,
    this.radius = 4,
    this.height = 4,
  });

  @override
  BoxPainter createBoxPainter([VoidCallback? onChanged]) {
    return _CustomTabIndicatorPainter(
      color: color,
      radius: radius,
      height: height,
    );
  }
}

class _CustomTabIndicatorPainter extends BoxPainter {
  final Color color;
  final double radius;
  final double height;

  _CustomTabIndicatorPainter({
    required this.color,
    required this.radius,
    required this.height,
  });

  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration configuration) {
    final Paint paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final double indicatorWidth = configuration.size!.width * 0.6;
    final double indicatorX = offset.dx + (configuration.size!.width - indicatorWidth) / 2;

    final RRect rRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        indicatorX,
        offset.dy + configuration.size!.height - height,
        indicatorWidth,
        height,
      ),
      Radius.circular(radius),
    );

    canvas.drawRRect(rRect, paint);
  }
}

// Enhanced floating action button for adding properties
class PropertyFloatingActionButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String? heroTag;
  final bool isExtended;

  const PropertyFloatingActionButton({
    super.key,
    this.onPressed,
    this.heroTag,
    this.isExtended = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isExtended) {
      return FloatingActionButton.extended(
        onPressed: onPressed,
        heroTag: heroTag,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_home_outlined),
        label: const Text(
          'Add Property',
          style: TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      );
    }

    return FloatingActionButton(
      onPressed: onPressed,
      heroTag: heroTag,
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Icon(Icons.add_home_outlined),
    );
  }
}