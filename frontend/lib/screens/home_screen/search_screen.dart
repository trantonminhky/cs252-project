import "package:flutter/material.dart";
import "package:flutter/cupertino.dart";
import "package:carousel_slider/carousel_slider.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:virtour_frontend/frontend_service_layer/place_service.dart";
import "package:virtour_frontend/providers/user_info_provider.dart";
import "package:virtour_frontend/screens/data_factories/place.dart";
import "package:virtour_frontend/screens/data_factories/filter_type.dart";
import "package:virtour_frontend/components/cards.dart";
import "package:virtour_frontend/screens/home_screen/place_overview.dart";

class SearchScreen extends ConsumerStatefulWidget {
  final String? initialSelectedCategory;

  const SearchScreen({
    super.key,
    this.initialSelectedCategory,
  });

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final RegionService _regionService = RegionService();

  List<String> _availableCategories = [];
  List<String> _selectedCategories = [];
  List<Place> _searchResults = [];
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializeCategories();

    // If an initial category is provided, make sure it's selected
    if (widget.initialSelectedCategory != null) {
      if (!_availableCategories.contains(widget.initialSelectedCategory)) {
        // Add to available categories if not present
        if (_availableCategories.length >= 5) {
          _availableCategories[4] = widget.initialSelectedCategory!;
        } else {
          _availableCategories.add(widget.initialSelectedCategory!);
        }
      }
      // Ensure it's in the selected list
      if (!_selectedCategories.contains(widget.initialSelectedCategory)) {
        _selectedCategories.add(widget.initialSelectedCategory!);
      }
    }
  }

  void _initializeCategories() {
    // Get user preferences
    final user = ref.read(userSessionProvider);
    List<String> userPreferences = user?.preferences ?? [];

    // Get all available categories
    List<String> allCategories =
        CategoryType.values.map((e) => e.name).toList();

    // Set available categories (5 categories to display)
    if (allCategories.length >= 5) {
      _availableCategories = allCategories.take(5).toList();
    } else {
      _availableCategories = List.from(allCategories);
    }

    // Initialize selected categories from user preferences
    _selectedCategories = userPreferences
        .where((pref) => _availableCategories.contains(pref))
        .toList();
  }

  String _normalizeCategoryName(String camelCaseCategory) {
    if (camelCaseCategory.isEmpty) return camelCaseCategory;

    // Add space before uppercase letters (except the first one)
    String normalized = camelCaseCategory
        .replaceAllMapped(
          RegExp(r'([A-Z])'),
          (match) => ' ${match.group(0)}',
        )
        .trim();

    // Capitalize only the first letter, lowercase the rest
    return normalized[0].toUpperCase() + normalized.substring(1).toLowerCase();
  }

  Future<void> _performSearch() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Use empty list if no categories are selected
      final filtersToUse = _selectedCategories.isEmpty
          ? <String>[]
          : List<String>.from(_selectedCategories);

      // Query is now optional - use text if available, otherwise empty string
      final query = _searchController.text.trim();

      final results = await _regionService.getPlace(
        query,
        filtersToUse,
      );
      setState(() {
        _searchResults = results;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  void _toggleCategory(String category) {
    setState(() {
      if (_selectedCategories.contains(category)) {
        _selectedCategories.remove(category);
      } else {
        _selectedCategories.add(category);
      }
    });
    // Always trigger search when categories change
    _performSearch();
  }

  Color _getCategoryColor(String category, int index) {
    final colors = [
      const Color(0xFFE91E63), // Pink
      const Color(0xFF9C27B0), // Purple
      const Color(0xFF3F51B5), // Indigo
      const Color(0xFF2196F3), // Blue
      const Color(0xFF00BCD4), // Cyan
      const Color(0xFF009688), // Teal
      const Color(0xFF4CAF50), // Green
      const Color(0xFFFF9800), // Orange
      const Color(0xFFFF5722), // Deep Orange
      const Color(0xFF795548), // Brown
    ];
    return colors[index % colors.length];
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Search bar with back button
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(CupertinoIcons.back, size: 30),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      autofocus: true,
                      textInputAction: TextInputAction.search,
                      onSubmitted: (value) {
                        _performSearch();
                      },
                      decoration: InputDecoration(
                        hintText: "Search for places...",
                        hintStyle: TextStyle(
                          color: Colors.grey[400],
                          fontFamily: "BeVietnamPro",
                        ),
                        prefixIcon: const Icon(CupertinoIcons.search),
                        filled: true,
                        fillColor: Colors.white,
                        enabledBorder: OutlineInputBorder(
                          borderSide: const BorderSide(width: 2),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(
                            width: 2,
                            color: Color(0xFFD72323),
                          ),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () {
                                  setState(() {
                                    _searchController.clear();
                                    _searchResults = [];
                                  });
                                },
                              )
                            : null,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // SizedBox with height 48
            const SizedBox(height: 16),

            // Two rows of category chips
            Column(
              children: [
                // First row
                SizedBox(
                  height: 50,
                  child: CarouselSlider(
                    options: CarouselOptions(
                      height: 50,
                      viewportFraction: 0.32,
                      enlargeCenterPage: false,
                      enableInfiniteScroll: false,
                      padEnds: false,
                    ),
                    items: _availableCategories
                        .take(6)
                        .toList()
                        .asMap()
                        .entries
                        .map((entry) {
                      final index = entry.key;
                      final category = entry.value;
                      final isSelected = _selectedCategories.contains(category);
                      final chipColor = _getCategoryColor(category, index);

                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        child: TextButton(
                          onPressed: () => _toggleCategory(category),
                          style: TextButton.styleFrom(
                            backgroundColor:
                                isSelected ? chipColor : Colors.transparent,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 5,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                              side: BorderSide(
                                color: chipColor,
                                width: 1.5,
                              ),
                            ),
                          ),
                          child: Text(
                            _normalizeCategoryName(category),
                            style: TextStyle(
                              color: isSelected ? Colors.white : chipColor,
                              fontSize: 14,
                              fontFamily: "BeVietnamPro",
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 12),
                // Second row
                SizedBox(
                  height: 50,
                  child: CarouselSlider(
                    options: CarouselOptions(
                      height: 50,
                      viewportFraction: 0.32,
                      enlargeCenterPage: false,
                      enableInfiniteScroll: false,
                      padEnds: false,
                    ),
                    items: _availableCategories
                        .skip(6)
                        .toList()
                        .asMap()
                        .entries
                        .map((entry) {
                      final index = entry.key + 6;
                      final category = entry.value;
                      final isSelected = _selectedCategories.contains(category);
                      final chipColor = _getCategoryColor(category, index);

                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        child: TextButton(
                          onPressed: () => _toggleCategory(category),
                          style: TextButton.styleFrom(
                            backgroundColor:
                                isSelected ? chipColor : Colors.transparent,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 5,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                              side: BorderSide(
                                color: chipColor,
                                width: 1.5,
                              ),
                            ),
                          ),
                          child: Text(
                            _normalizeCategoryName(category),
                            style: TextStyle(
                              color: isSelected ? Colors.white : chipColor,
                              fontSize: 14,
                              fontFamily: "BeVietnamPro",
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),

            // SizedBox with height 48
            const SizedBox(height: 48),

            // Search results list
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _errorMessage != null
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Text(
                              _errorMessage!,
                              style: const TextStyle(color: Colors.red),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        )
                      : _searchResults.isEmpty
                          ? Center(
                              child: Text(
                                _searchController.text.isEmpty
                                    ? "Start typing to search..."
                                    : "No places found",
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontFamily: "BeVietnamPro",
                                ),
                              ),
                            )
                          : ListView.builder(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              itemCount: _searchResults.length,
                              itemBuilder: (context, index) {
                                final place = _searchResults[index];
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: Cards(
                                    size: CardSize.horiz,
                                    imageUrl: place.imageLink,
                                    title: place.name,
                                    subtitle: '${place.lat}, ${place.lon}',
                                    chips: place.tags.values
                                        .expand((list) => list)
                                        .take(2)
                                        .map(
                                          (cat) => (
                                            label: cat,
                                            backgroundColor:
                                                const Color(0xFFD72323)
                                          ),
                                        )
                                        .toList(),
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        CupertinoPageRoute(
                                          builder: (context) =>
                                              PlaceOverview(place: place),
                                        ),
                                      );
                                    },
                                  ),
                                );
                              },
                            ),
            ),
          ],
        ),
      ),
    );
  }
}
