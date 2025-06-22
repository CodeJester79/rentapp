import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/app_constants.dart';

class ModernSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final VoidCallback? onFilterTap;
  final ValueChanged<String>? onSubmitted;
  final ValueChanged<String>? onChanged;
  final bool showFilter;

  const ModernSearchBar({
    super.key,
    required this.controller,
    this.hintText = 'Search properties...',
    this.onFilterTap,
    this.onSubmitted,
    this.onChanged,
    this.showFilter = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.neutral200.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        onSubmitted: onSubmitted,
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(
            color: AppColors.neutral400,
            fontSize: 16,
          ),
          prefixIcon: Icon(
            Icons.search_rounded,
            color: AppColors.neutral500,
            size: 24,
          ),
          suffixIcon: showFilter
              ? IconButton(
                  icon: Icon(
                    Icons.tune_rounded,
                    color: AppColors.primary,
                  ),
                  onPressed: onFilterTap,
                )
              : null,
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
      ),
    );
  }
}

class PriceRangeSlider extends StatefulWidget {
  final double minPrice;
  final double maxPrice;
  final RangeValues currentRange;
  final ValueChanged<RangeValues> onChanged;

  const PriceRangeSlider({
    super.key,
    required this.minPrice,
    required this.maxPrice,
    required this.currentRange,
    required this.onChanged,
  });

  @override
  State<PriceRangeSlider> createState() => _PriceRangeSliderState();
}

class _PriceRangeSliderState extends State<PriceRangeSlider> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Price Range',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '\$${widget.currentRange.start.toInt()}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
            ),
            Text(
              '\$${widget.currentRange.end.toInt()}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        RangeSlider(
          values: widget.currentRange,
          min: widget.minPrice,
          max: widget.maxPrice,
          divisions: 100,
          activeColor: AppColors.primary,
          inactiveColor: AppColors.neutral200,
          onChanged: widget.onChanged,
        ),
      ],
    );
  }
}

class PropertyTypeSelector extends StatelessWidget {
  final List<String> propertyTypes;
  final String? selectedType;
  final ValueChanged<String?> onChanged;

  const PropertyTypeSelector({
    super.key,
    required this.propertyTypes,
    this.selectedType,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Property Type',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildTypeChip('All', selectedType == null, () => onChanged(null)),
            ...propertyTypes.map(
              (type) => _buildTypeChip(
                type,
                selectedType == type,
                () => onChanged(type),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTypeChip(String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.neutral300,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : AppColors.neutral600,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}

class BedroomBathroomSelector extends StatelessWidget {
  final String label;
  final int minValue;
  final int maxValue;
  final int? selectedValue;
  final ValueChanged<int?> onChanged;

  const BedroomBathroomSelector({
    super.key,
    required this.label,
    this.minValue = 0,
    this.maxValue = 5,
    this.selectedValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          children: [
            _buildNumberChip('Any', selectedValue == null, () => onChanged(null)),
            ...List.generate(
              maxValue - minValue + 1,
              (index) {
                final value = minValue + index;
                final displayText = value == maxValue ? '$value+' : '$value';
                return _buildNumberChip(
                  displayText,
                  selectedValue == value,
                  () => onChanged(value),
                );
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildNumberChip(String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.neutral300,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : AppColors.neutral600,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }
}

class FilterBottomSheet extends StatefulWidget {
  final double minPrice;
  final double maxPrice;
  final RangeValues priceRange;
  final String? selectedPropertyType;
  final int? selectedBedrooms;
  final int? selectedBathrooms;
  final VoidCallback onReset;
  final Function({
    RangeValues? priceRange,
    String? propertyType,
    int? bedrooms,
    int? bathrooms,
  }) onApply;

  const FilterBottomSheet({
    super.key,
    required this.minPrice,
    required this.maxPrice,
    required this.priceRange,
    this.selectedPropertyType,
    this.selectedBedrooms,
    this.selectedBathrooms,
    required this.onReset,
    required this.onApply,
  });

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  late RangeValues _currentPriceRange;
  String? _currentPropertyType;
  int? _currentBedrooms;
  int? _currentBathrooms;

  @override
  void initState() {
    super.initState();
    _currentPriceRange = widget.priceRange;
    _currentPropertyType = widget.selectedPropertyType;
    _currentBedrooms = widget.selectedBedrooms;
    _currentBathrooms = widget.selectedBathrooms;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.neutral300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Filters',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _currentPriceRange = RangeValues(widget.minPrice, widget.maxPrice);
                      _currentPropertyType = null;
                      _currentBedrooms = null;
                      _currentBathrooms = null;
                    });
                  },
                  child: Text(
                    'Reset',
                    style: TextStyle(
                      color: AppColors.error,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          // Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Price Range
                PriceRangeSlider(
                  minPrice: widget.minPrice,
                  maxPrice: widget.maxPrice,
                  currentRange: _currentPriceRange,
                  onChanged: (range) {
                    setState(() {
                      _currentPriceRange = range;
                    });
                  },
                ),
                const SizedBox(height: 24),
                // Property Type
                PropertyTypeSelector(
                  propertyTypes: AppConstants.propertyTypes,
                  selectedType: _currentPropertyType,
                  onChanged: (type) {
                    setState(() {
                      _currentPropertyType = type;
                    });
                  },
                ),
                const SizedBox(height: 24),
                // Bedrooms
                BedroomBathroomSelector(
                  label: 'Bedrooms',
                  maxValue: AppConstants.maxBedrooms,
                  selectedValue: _currentBedrooms,
                  onChanged: (bedrooms) {
                    setState(() {
                      _currentBedrooms = bedrooms;
                    });
                  },
                ),
                const SizedBox(height: 24),
                // Bathrooms
                BedroomBathroomSelector(
                  label: 'Bathrooms',
                  maxValue: AppConstants.maxBathrooms,
                  selectedValue: _currentBathrooms,
                  onChanged: (bathrooms) {
                    setState(() {
                      _currentBathrooms = bathrooms;
                    });
                  },
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
          // Apply Button
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                  widget.onApply(
                    priceRange: _currentPriceRange,
                    propertyType: _currentPropertyType,
                    bedrooms: _currentBedrooms,
                    bathrooms: _currentBathrooms,
                  );
                  Navigator.of(context).pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  'Apply Filters',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
          // Safe area
          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }
}