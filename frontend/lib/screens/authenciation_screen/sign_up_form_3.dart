import 'package:flutter/material.dart';
import 'package:virtour_frontend/screens/data_factories/filter_type.dart';

class SignUpForm3 extends StatefulWidget {
  final VoidCallback onNext;
  final VoidCallback onPrevious;
  final TextEditingController interestsController;
  final TextEditingController userTypeController;
  final Function(List<String>) onPreferencesSelected;

  const SignUpForm3({
    super.key,
    required this.onNext,
    required this.onPrevious,
    required this.interestsController,
    required this.userTypeController,
    required this.onPreferencesSelected,
  });

  @override
  State<SignUpForm3> createState() => _SignUpForm3State();
}

class _SignUpForm3State extends State<SignUpForm3> {
  final Set<FilterType> _selectedMainCategories = {};
  final Set<CategoryType> _selectedSubCategories = {};
  final Map<FilterType, bool> _expandedCategories = {};

  @override
  void initState() {
    super.initState();
    // Initialize all categories as collapsed
    for (var category in FilterType.values) {
      if (category != FilterType.regionOverview) {
        _expandedCategories[category] = false;
      }
    }
  }

  void _toggleMainCategory(FilterType category) {
    setState(() {
      if (_selectedMainCategories.contains(category)) {
        // Deselect main category and all its subcategories
        _selectedMainCategories.remove(category);
        _expandedCategories[category] = false;

        // Remove all subcategories of this main category
        final subCategories = filterCategoryMapping[category] ?? [];
        for (var subCat in subCategories) {
          _selectedSubCategories.remove(subCat);
        }
      } else {
        // Select and expand main category
        _selectedMainCategories.add(category);
        _expandedCategories[category] = true;
      }

      // Update controller with selected interests
      _updateInterestsController();
    });
  }

  void _toggleSubCategory(CategoryType category) {
    setState(() {
      if (_selectedSubCategories.contains(category)) {
        _selectedSubCategories.remove(category);
      } else {
        _selectedSubCategories.add(category);
      }

      // Update controller
      _updateInterestsController();
    });
  }

  void _updateInterestsController() {
    final interests = [
      ..._selectedMainCategories.map((c) => c.name),
      ..._selectedSubCategories.map((c) => c.name),
    ];
    widget.interestsController.text = interests.join(', ');

    // Pass the selected subcategories to parent
    final subcategoriesOnly =
        _selectedSubCategories.map((c) => c.name).toList();
    widget.onPreferencesSelected(subcategoriesOnly);
  }

  String _formatCategoryName(String name) {
    // Convert camelCase to Title Case with spaces
    return name
        .replaceAllMapped(
          RegExp(r'([A-Z])'),
          (match) => ' ${match.group(0)}',
        )
        .trim()
        .split(' ')
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }

  Widget _buildCategoryButton({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    bool isSubCategory = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: isSubCategory ? 16 : 24,
          vertical: isSubCategory ? 12 : 16,
        ),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFD72323) : Colors.white,
          border: Border.all(
            color: isSelected ? const Color(0xFFD72323) : Colors.black,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black,
            fontSize: isSubCategory ? 14 : 16,
            fontFamily: 'BeVietnamPro',
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  List<Widget> _buildCategoryRows() {
    final List<Widget> rows = [];

    for (var mainCategory in FilterType.values) {
      if (mainCategory == FilterType.regionOverview) continue;

      final isMainSelected = _selectedMainCategories.contains(mainCategory);
      final isExpanded = _expandedCategories[mainCategory] ?? false;
      final subCategories = filterCategoryMapping[mainCategory] ?? [];

      // Main category button
      rows.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Align(
            alignment: Alignment.centerLeft,
            child: _buildCategoryButton(
              label: _formatCategoryName(mainCategory.name),
              isSelected: isMainSelected,
              onTap: () => _toggleMainCategory(mainCategory),
            ),
          ),
        ),
      );

      // Subcategory buttons (if expanded)
      if (isExpanded && subCategories.isNotEmpty) {
        rows.add(
          Padding(
            padding: const EdgeInsets.only(left: 20, bottom: 12),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: subCategories.map((subCategory) {
                final isSubSelected =
                    _selectedSubCategories.contains(subCategory);
                return _buildCategoryButton(
                  label: _formatCategoryName(subCategory.name),
                  isSelected: isSubSelected,
                  onTap: () => _toggleSubCategory(subCategory),
                  isSubCategory: true,
                );
              }).toList(),
            ),
          ),
        );
      }
    }

    return rows;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 24, left: 32, right: 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Tell us about your interests...",
            style: TextStyle(
              color: Colors.black,
              fontSize: 24,
              fontFamily: "BeVietnamPro",
              fontWeight: FontWeight.w700,
              letterSpacing: -1,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Select categories to personalize your experience',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
              fontFamily: 'BeVietnamPro',
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 24),

          // Scrollable Category Selection
          SizedBox(
            height: 300,
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: _buildCategoryRows(),
              ),
            ),
          ),

          // Selected Count Indicator
          Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${_selectedMainCategories.length + _selectedSubCategories.length} interests selected',
              style: const TextStyle(
                fontSize: 16,
                fontFamily: 'BeVietnamPro',
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          const SizedBox(height: 16),
          Padding(
            padding: EdgeInsets.zero,
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: widget.onPrevious,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 32, vertical: 16),
                      decoration: ShapeDecoration(
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                          side: const BorderSide(
                              width: 2,
                              strokeAlign: BorderSide.strokeAlignInside),
                          borderRadius: BorderRadius.circular(13),
                        ),
                      ),
                      child: const Center(
                        child: Text(
                          'Back',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontFamily: 'Be Vietnam',
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: GestureDetector(
                    onTap: widget.onNext,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 32, vertical: 16),
                      decoration: ShapeDecoration(
                        color: const Color(0xffd72323),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Center(
                        child: Text(
                          'Done',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontFamily: 'Be Vietnam',
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
