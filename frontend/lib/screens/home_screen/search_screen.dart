import "package:flutter/material.dart";
import "package:flutter/cupertino.dart";
import "package:carousel_slider/carousel_slider.dart";
import "package:virtour_frontend/screens/data_factories/data_service.dart";
import "package:virtour_frontend/screens/data_factories/place.dart";
import "package:virtour_frontend/screens/data_factories/filter_type.dart";
import "package:virtour_frontend/components/cards.dart";
import "package:virtour_frontend/constants/userinfo.dart";
import "package:virtour_frontend/screens/home_screen/place_overview.dart";

class SearchScreen extends StatefulWidget {
  final String? initialSelectedCategory;

  const SearchScreen({
    super.key,
    this.initialSelectedCategory,
  });

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final RegionService _regionService = RegionService();
  final UserInfo _userInfo = UserInfo();

  List<String> _selectedCategories = [];
  List<Place> _searchResults = [];
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializeCategories();

    // If an initial category is provided, ensure it's in the selected list
    if (widget.initialSelectedCategory != null) {
      if (!_selectedCategories.contains(widget.initialSelectedCategory)) {
        // Add the initial category if not already present
        if (_selectedCategories.length >= 5) {
          // Replace the last one
          _selectedCategories[4] = widget.initialSelectedCategory!;
        } else {
          _selectedCategories.add(widget.initialSelectedCategory!);
        }
      }
    }
  }

  void _initializeCategories() {
    // Get user preferences
    List<String> userPreferences = _userInfo.preferences;

    // Get all available categories
    List<String> allCategories =
        CategoryType.values.map((e) => e.name).toList();

    // Ensure we have exactly 5 categories
    if (userPreferences.length >= 5) {
      _selectedCategories = userPreferences.take(5).toList();
    } else {
      _selectedCategories = List.from(userPreferences);
      // Add more categories from all categories if needed
      for (var category in allCategories) {
        if (_selectedCategories.length >= 5) break;
        if (!_selectedCategories.contains(category)) {
          _selectedCategories.add(category);
        }
      }
    }
  }

  Future<void> _performSearch() async {
    // Only search if there's text entered
    if (_searchController.text.trim().isEmpty) {
      setState(() {
        _searchResults = [];
        _errorMessage = null;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Use empty list if no categories are selected
      final filtersToUse = _selectedCategories.isEmpty
          ? <String>[]
          : List<String>.from(_selectedCategories);
      final results = await _regionService.getFilteredPlaces(
        _searchController.text,
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
    // Re-trigger search if there's already text entered
    if (_searchController.text.trim().isNotEmpty) {
      _performSearch();
    }
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
            const SizedBox(height: 48),

            // Carousel of category chips
            SizedBox(
              height: 50,
              child: CarouselSlider(
                options: CarouselOptions(
                  height: 50,
                  viewportFraction: 0.25,
                  enlargeCenterPage: false,
                  enableInfiniteScroll: false,
                  padEnds: false,
                ),
                items: _selectedCategories.map((category) {
                  final isSelected = _selectedCategories.contains(category);
                  return GestureDetector(
                    onTap: () => _toggleCategory(category),
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFFD72323)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: isSelected
                              ? const Color(0xFFD72323)
                              : Colors.grey,
                          width: 1.5,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          category,
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.black87,
                            fontSize: 14,
                            fontFamily: "BeVietnamPro",
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
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
                                    imageUrl: place.imageUrl,
                                    title: place.name,
                                    subtitle: place.address,
                                    chips: place.categories
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
