import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/app_constants.dart';

class EmptyStateWidget extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final String? actionText;
  final VoidCallback? onActionPressed;
  final Widget? customAction;
  final double iconSize;

  const EmptyStateWidget({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.actionText,
    this.onActionPressed,
    this.customAction,
    this.iconSize = 80,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.neutral100,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: iconSize,
                color: AppColors.neutral400,
              ),
            ),
            const SizedBox(height: 24),
            // Title
            Text(
              title,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: AppColors.neutral800,
                    fontWeight: FontWeight.w600,
                  ),
              textAlign: TextAlign.center,
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 8),
              Text(
                subtitle!,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppColors.neutral600,
                    ),
                textAlign: TextAlign.center,
              ),
            ],
            if (customAction != null) ...[
              const SizedBox(height: 24),
              customAction!,
            ] else if (actionText != null && onActionPressed != null) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: onActionPressed,
                icon: const Icon(Icons.add),
                label: Text(actionText!),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class NoPropertiesWidget extends StatelessWidget {
  final VoidCallback? onAddProperty;
  final bool canAddProperty;

  const NoPropertiesWidget({
    super.key,
    this.onAddProperty,
    this.canAddProperty = false,
  });

  @override
  Widget build(BuildContext context) {
    return EmptyStateWidget(
      icon: Icons.home_outlined,
      title: AppConstants.noPropertiesMessage,
      subtitle: 'Properties will appear here once they are available.',
      actionText: canAddProperty ? 'Add Property' : null,
      onActionPressed: canAddProperty ? onAddProperty : null,
    );
  }
}

class NoFavoritesWidget extends StatelessWidget {
  final VoidCallback? onExploreProperties;

  const NoFavoritesWidget({
    super.key,
    this.onExploreProperties,
  });

  @override
  Widget build(BuildContext context) {
    return EmptyStateWidget(
      icon: Icons.favorite_border,
      title: AppConstants.noFavoritesMessage,
      subtitle: 'Save properties you love to see them here.',
      actionText: 'Explore Properties',
      onActionPressed: onExploreProperties,
    );
  }
}

class NoSearchResultsWidget extends StatelessWidget {
  final String? searchQuery;
  final VoidCallback? onClearFilters;

  const NoSearchResultsWidget({
    super.key,
    this.searchQuery,
    this.onClearFilters,
  });

  @override
  Widget build(BuildContext context) {
    return EmptyStateWidget(
      icon: Icons.search_off,
      title: AppConstants.noSearchResultsMessage,
      subtitle: searchQuery != null
          ? 'No results found for "$searchQuery". Try adjusting your search.'
          : 'Try adjusting your filters or search terms.',
      actionText: 'Clear Filters',
      onActionPressed: onClearFilters,
    );
  }
}

class NoCommentsWidget extends StatelessWidget {
  final VoidCallback? onAddComment;

  const NoCommentsWidget({
    super.key,
    this.onAddComment,
  });

  @override
  Widget build(BuildContext context) {
    return EmptyStateWidget(
      icon: Icons.comment_outlined,
      title: AppConstants.noCommentsMessage,
      subtitle: 'Be the first to leave a comment about this property.',
      actionText: 'Add Comment',
      onActionPressed: onAddComment,
    );
  }
}

class NoInquiriesWidget extends StatelessWidget {
  const NoInquiriesWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return EmptyStateWidget(
      icon: Icons.question_answer_outlined,
      title: AppConstants.noInquiriesMessage,
      subtitle: 'Customer inquiries will appear here.',
    );
  }
}

class ErrorStateWidget extends StatelessWidget {
  final IconData? icon;
  final String title;
  final String? subtitle;
  final String? actionText;
  final VoidCallback? onActionPressed;

  const ErrorStateWidget({
    super.key,
    this.icon,
    required this.title,
    this.subtitle,
    this.actionText,
    this.onActionPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Error Icon
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.errorLight,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon ?? Icons.error_outline,
                size: 64,
                color: AppColors.error,
              ),
            ),
            const SizedBox(height: 24),
            // Title
            Text(
              title,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: AppColors.neutral800,
                    fontWeight: FontWeight.w600,
                  ),
              textAlign: TextAlign.center,
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 8),
              Text(
                subtitle!,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppColors.neutral600,
                    ),
                textAlign: TextAlign.center,
              ),
            ],
            if (actionText != null && onActionPressed != null) ...[
              const SizedBox(height: 24),
              OutlinedButton.icon(
                onPressed: onActionPressed,
                icon: const Icon(Icons.refresh),
                label: Text(actionText!),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class NetworkErrorWidget extends StatelessWidget {
  final VoidCallback? onRetry;

  const NetworkErrorWidget({
    super.key,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return ErrorStateWidget(
      icon: Icons.wifi_off,
      title: 'Connection Error',
      subtitle: AppConstants.networkErrorMessage,
      actionText: 'Retry',
      onActionPressed: onRetry,
    );
  }
}

class GenericErrorWidget extends StatelessWidget {
  final VoidCallback? onRetry;

  const GenericErrorWidget({
    super.key,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return ErrorStateWidget(
      title: 'Something went wrong',
      subtitle: AppConstants.genericErrorMessage,
      actionText: 'Try Again',
      onActionPressed: onRetry,
    );
  }
}