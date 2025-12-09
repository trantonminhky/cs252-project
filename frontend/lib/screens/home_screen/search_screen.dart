import "dart:async";
import "dart:math" as math;
import "package:flutter/material.dart";
import "package:flutter/cupertino.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:virtour_frontend/frontend_service_layer/place_service.dart";
import "package:virtour_frontend/providers/user_info_provider.dart";
import "package:virtour_frontend/screens/data_factories/place.dart";
import "package:virtour_frontend/screens/data_factories/filter_type.dart";
import "package:virtour_frontend/components/cards.dart";
import "package:virtour_frontend/screens/home_screen/place_overview.dart";
import "package:virtour_frontend/frontend_service_layer/search_cache_service.dart";

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
  final SearchCacheService _cacheService = SearchCacheService();
  Timer? _debounce;

  List<String> _availableCategories = [];
  List<String> _selectedCategories = [];
  List<Place> _searchResults = [];
  List<Place> _recentPlaces = [];
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializeCategories();
    _loadRecentPlaces();

    // Add listener to search controller for real-time search
    _searchController.addListener(_onSearchChanged);

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

  void _onSearchChanged() {
    // Cancel previous timer if it exists
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    // Set a new timer for debouncing (500ms delay)
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (_searchController.text.isNotEmpty) {
        _performSearch();
      } else {
        // Clear results when search is empty to show cache again
        setState(() {
          _searchResults = [];
        });
        // Reload recent places to ensure cache is fresh
        _loadRecentPlaces();
      }
    });
  }

  Future<void> _loadRecentPlaces() async {
    try {
      final recent = await _cacheService.getCache();
      if (mounted) {
        setState(() {
          _recentPlaces = recent.take(5).toList();
        });
      }
    } catch (e) {
      print('Error loading recent places: $e');
      if (mounted) {
        setState(() {
          _recentPlaces = [];
        });
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

    // Set available categories
    _availableCategories = List.from(allCategories);

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
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _searchResults = []; // Clear previous results immediately
    });

    try {
      // Use empty list if no categories are selected
      final filtersToUse = _selectedCategories.isEmpty
          ? <String>[]
          : List<String>.from(_selectedCategories);

      // Query is now optional - use text if available, otherwise empty string
      final query = _searchController.text.trim();

      // Fetch from API
      final results = await _regionService.getPlace(
        query,
        filtersToUse,
      );

      if (mounted) {
        setState(() {
          _searchResults = results;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  void _navigateToRecentPlace(Place place) {
    Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (context) => PlaceOverview(place: place),
      ),
    );
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
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenHeight = mediaQuery.size.height;

    final double availableHeight = screenHeight -
        mediaQuery.viewInsets.bottom -
        mediaQuery.padding.top -
        300.0;

    final double maxDropdownHeight = math.max(
        0.0, // Minimum usable height
        math.min(screenHeight * 0.4, availableHeight));

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
                          fontWeight: FontWeight.w400,
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

            // Dropdown / Accordion for Categories
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Theme(
                  data: Theme.of(context).copyWith(
                    dividerColor: Colors.transparent,
                  ),
                  child: ExpansionTile(
                    tilePadding: const EdgeInsets.symmetric(horizontal: 16),
                    iconColor: const Color(0xFFD72323),
                    textColor: const Color(0xFFD72323),
                    title: Text(
                      _selectedCategories.isEmpty
                          ? "Filter by Category"
                          : "${_selectedCategories.length} filters selected",
                      style: const TextStyle(
                        fontFamily: "BeVietnamPro",
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    children: [
                      Container(
                        constraints: BoxConstraints(
                          maxHeight: maxDropdownHeight,
                        ),
                        child: SingleChildScrollView(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                            child: SizedBox(
                              width: double.infinity,
                              child: Wrap(
                                spacing: 8.0,
                                runSpacing: 8.0,
                                children: _availableCategories
                                    .asMap()
                                    .entries
                                    .map((entry) {
                                  final index = entry.key;
                                  final category = entry.value;
                                  final isSelected =
                                      _selectedCategories.contains(category);
                                  final chipColor =
                                      _getCategoryColor(category, index);

                                  return FilterChip(
                                    label: Text(
                                      _normalizeCategoryName(category),
                                      style: TextStyle(
                                        color: isSelected
                                            ? Colors.white
                                            : Colors.black87,
                                        fontFamily: "BeVietnamPro",
                                        fontWeight: FontWeight.w500,
                                        fontSize: 13,
                                      ),
                                    ),
                                    selected: isSelected,
                                    onSelected: (_) =>
                                        _toggleCategory(category),
                                    backgroundColor: Colors.white,
                                    selectedColor: chipColor,
                                    checkmarkColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 8),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                      side: BorderSide(
                                        color: isSelected
                                            ? Colors.transparent
                                            : Colors.grey.shade300,
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

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
                          ? _buildEmptyState()
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
                                      // Add to cache when viewing
                                      _cacheService.addCache(place);
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

  Widget _buildEmptyState() {
    if (_searchController.text.isNotEmpty) {
      return Center(
        child: Text(
          "No places found",
          style: TextStyle(
            color: Colors.grey[600],
            fontFamily: "BeVietnamPro",
          ),
        ),
      );
    }

    // Show recent places if available
    if (_recentPlaces.isEmpty) {
      return Center(
        child: Text(
          "Start typing to search...",
          style: TextStyle(
            color: Colors.grey[600],
            fontFamily: "BeVietnamPro",
          ),
        ),
      );
    }

    // Display recent places
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Recently Viewed",
                style: TextStyle(
                  color: Colors.grey[800],
                  fontSize: 18,
                  fontFamily: "BeVietnamPro",
                  fontWeight: FontWeight.w600,
                ),
              ),
              TextButton(
                onPressed: () async {
                  await _cacheService.writeCache([]);
                  await _loadRecentPlaces();
                },
                child: const Text(
                  "Clear",
                  style: TextStyle(
                    color: Color(0xFFD72323),
                    fontFamily: "BeVietnamPro",
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: ListView.builder(
              itemCount: _recentPlaces.length,
              itemBuilder: (context, index) {
                final place = _recentPlaces[index];

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
                            backgroundColor: const Color(0xFFD72323)
                          ),
                        )
                        .toList(),
                    onTap: () => _navigateToRecentPlace(place),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
