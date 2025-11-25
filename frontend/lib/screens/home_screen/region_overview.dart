import "package:flutter/material.dart";
import "package:flutter/cupertino.dart";
import "package:virtour_frontend/components/briefings.dart";
import "package:virtour_frontend/components/cards.dart";
import "package:virtour_frontend/screens/home_screen/place_overview.dart";
import "package:virtour_frontend/screens/home_screen/helpers.dart";
import "package:virtour_frontend/screens/data_factories/filter_type.dart";
import "package:virtour_frontend/screens/data_factories/region.dart";
import "package:virtour_frontend/screens/data_factories/place.dart";
import "package:virtour_frontend/screens/data_factories/region_service.dart";

class RegionOverview extends StatefulWidget {
  final String regionId;
  final String regionName;
  final FilterType currentFilter;
  const RegionOverview(
      {super.key,
      required this.regionId,
      required this.regionName,
      required this.currentFilter});

  @override
  State<RegionOverview> createState() => _RegionOverviewState();
}

class _RegionOverviewState extends State<RegionOverview> {
  bool _isExpanded = false; // Track "Read More" state

  // Data state
  Region? _region;
  List<Place>? _allPlaces; // Store all places
  List<Place>? _filteredPlaces;
  bool _isLoading = true;
  String? _errorMessage;
  FilterType _currentFilter = FilterType.regionOverview;

  final RegionService _regionService = RegionService();

  @override
  void initState() {
    super.initState();
    _currentFilter = widget.currentFilter;
    _loadRegionData();
  }

  Future<void> _loadRegionData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Fetch region data
      final region = await _regionService.getRegionbyId(widget.regionId);

      // Fetch all places for this region (service uses regionId, not placeIds list)
      final places = await _regionService.fetchPlaceById(widget.regionId);

      // Filter places based on current filter
      final filteredPlaces =
          _regionService.filterPlaces(places, _currentFilter);

      setState(() {
        _region = region;
        _allPlaces = places; // Store all places
        _filteredPlaces = filteredPlaces;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  void _updateFilter(FilterType newFilter) {
    if (_allPlaces == null) return;

    setState(() {
      _currentFilter = newFilter;
      _filteredPlaces = _regionService.filterPlaces(_allPlaces!, newFilter);
    });
  }

  @override
  Widget build(BuildContext context) {
    // Calculate card width (screen width - 40px padding)
    final double screenWidth = MediaQuery.of(context).size.width;
    final double cardWidth = screenWidth - 40;

    // Original briefing width is 372, height is 300
    // Scale factor to match card width while maintaining aspect ratio
    final double scaleFactor = cardWidth / 372;
    final double briefingHeight = 300 * scaleFactor;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _errorMessage != null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline,
                            size: 48, color: Colors.red),
                        const SizedBox(height: 16),
                        const Text(
                          'Error loading region',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _errorMessage!,
                          style: TextStyle(color: Colors.grey[600]),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _loadRegionData,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  )
                : SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Back button
                        Padding(
                          padding: const EdgeInsets.only(left: 10, top: 10),
                          child: IconButton(
                            icon: const Icon(CupertinoIcons.back, size: 40),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ),
                        const SizedBox(height: 24),
                        // Filters
                        SizedBox(
                          height: 50,
                          child: ListView(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            children: [
                              _buildFilterChip(
                                FilterType.regionOverview,
                                "Region overview",
                                CupertinoIcons.book,
                              ),
                              const SizedBox(width: 8),
                              _buildFilterChip(
                                FilterType.architecture,
                                "Architecture",
                                Icons.account_balance,
                              ),
                              const SizedBox(width: 8),
                              _buildFilterChip(
                                FilterType.ethnic,
                                "Ethnic",
                                CupertinoIcons.person,
                              ),
                              const SizedBox(width: 8),
                              _buildFilterChip(
                                FilterType.origin,
                                "Origin",
                                Icons.public,
                              ),
                              const SizedBox(width: 8),
                              _buildFilterChip(
                                FilterType.religion,
                                "Religion",
                                Icons.church,
                              ),
                              const SizedBox(width: 8),
                              _buildFilterChip(
                                FilterType.culture,
                                "Culture",
                                CupertinoIcons.heart,
                              ),
                              const SizedBox(width: 8),
                              _buildFilterChip(
                                FilterType.historical,
                                "Historical",
                                CupertinoIcons.time,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Briefing
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: SizedBox(
                            width: cardWidth,
                            height: briefingHeight,
                            child: Briefing(
                              size: BriefingSize.full,
                              title: _region?.name ?? "Saigon",
                              category: "Region",
                              imageUrl: _region?.imageUrl ??
                                  "../assets/images/places/Saigon.png",
                            ),
                          ),
                        ),
                        // Description section with grey background
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Container(
                            width: cardWidth,
                            color: Colors.grey[100],
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _isExpanded
                                      ? (_region?.description ?? "")
                                      : getTruncatedDescription(
                                          _region?.description ?? ""),
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontFamily: "BeVietnamPro",
                                    fontWeight: FontWeight.w400,
                                    color: Colors.black87,
                                    height: 1.5,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _isExpanded = !_isExpanded;
                                    });
                                  },
                                  child: Text(
                                    _isExpanded ? "Read Less" : "Read More",
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontFamily: "BeVietnamPro",
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xffd72323),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        // "Where to go?" heading
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          child: Text(
                            "Where to go?",
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 20,
                              fontFamily: "BeVietnamPro",
                              fontWeight: FontWeight.w700,
                              letterSpacing: -1,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Cards section - dynamically generated from filtered places
                        if (_filteredPlaces != null &&
                            _filteredPlaces!.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Column(
                              children: _filteredPlaces!.map((place) {
                                return Column(
                                  children: [
                                    GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          CupertinoPageRoute(
                                            builder: (context) =>
                                                PlaceOverview(place: place),
                                          ),
                                        );
                                      },
                                      child: Cards(
                                        size: CardSize.list,
                                        title: place.name,
                                        chips: getChipsFromPlace(place),
                                        imageUrl: place.imageUrl,
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                  ],
                                );
                              }).toList(),
                            ),
                          )
                        else
                          const Padding(
                            padding: EdgeInsets.all(40),
                            child: Center(
                              child: Text(
                                "No places found for this filter",
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                          ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
      ),
    );
  }

  // Helper method to build filter chips
  Widget _buildFilterChip(FilterType filterType, String label, IconData icon) {
    final bool isSelected = _currentFilter == filterType;
    return FilterChip(
      avatar: CircleAvatar(
        foregroundColor: isSelected ? Colors.white : Colors.grey,
        backgroundColor: isSelected ? Colors.white : Colors.grey,
        child: Icon(icon, color: Colors.white, size: 16),
      ),
      disabledColor: Colors.white,
      selectedColor: const Color(0xffe0e0e0),
      side: BorderSide(
        color: isSelected ? Colors.black : Colors.grey,
        width: 2,
      ),
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (selected && !isSelected) {
          _updateFilter(filterType);
        }
      },
    );
  }
}
