import "package:flutter/cupertino.dart";
import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:virtour_frontend/components/briefings.dart";
import "package:virtour_frontend/components/custom_text_field.dart";
import "package:virtour_frontend/components/events_banner.dart";
import "package:virtour_frontend/components/briefing_carousel.dart";
import "package:virtour_frontend/providers/user_info_provider.dart";
import "package:virtour_frontend/screens/home_screen/region_overview.dart";
import "package:virtour_frontend/screens/home_screen/place_overview.dart";
import "package:virtour_frontend/screens/home_screen/search_screen.dart";
import "package:virtour_frontend/screens/data_factories/place.dart";
import "package:virtour_frontend/frontend_service_layer/place_service.dart";
import "package:virtour_frontend/providers/event_provider.dart";
import "package:virtour_frontend/screens/data_factories/filter_type.dart";
import "package:virtour_frontend/screens/data_factories/region.dart";

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  final RegionService _regionService = RegionService();

  List<Place> _topDestinations = [];
  List<Place> _allPlaces = []; // Cache for all places
  bool _isLoadingDestinations = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchTopDestinations();
    print("initing");
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchTopDestinations() async {
    setState(() {
      _isLoadingDestinations = true;
      _errorMessage = null;
    });

    final user = ref.read(userSessionProvider);
    if (user == null || user.userID.isEmpty) {
      _topDestinations = [];
      _isLoadingDestinations = false;
      return;
    }

    try {
      final userID = user.userID;

      // Use default location (Ho Chi Minh City center) - can be replaced with user's actual location
      const double lat = 10.8231;
      const double lon = 106.6297;

      // Fetch places once and cache them
      //_allPlaces = await _regionService.getPlace("", []);

      final locationIDs =
          await _regionService.fetchRecommendations(userID, lat, lon);

      _topDestinations = await _regionService.getAllPlaces(locationIDs);

      setState(() {
        // _topDestinations = _allPlaces; // Can be filtered based on locationIds if needed
        _isLoadingDestinations = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load recommendations: $e';
        _isLoadingDestinations = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load recommendations: $e')),
        );
      }
    }
  }

  Widget _buildTopRegions() {
    return FullBriefingCarousel(
      height: 320,
      autoPlay: true,
      items: [
        GestureDetector(
          onTap: () {
            // Use cached places instead of fetching again
            if (mounted) {
              Navigator.push(
                context,
                CupertinoPageRoute(
                  builder: (context) => RegionOverview(
                    region: const Region(
                      id: "saigon",
                      name: "Southern Vietnam",
                      description:
                          "Explore the vibrant culture and bustling cities of Southern Vietnam.",
                      imageUrl: "../assets/images/regions/Saigon.jpg",
                      //placeholder
                      placesId: ["place1", "place2", "place3"],
                    ),
                    currentFilter: FilterType.regionOverview,
                    places: _allPlaces,
                  ),
                ),
              );
            }
          },
          child: const Briefing(
            size: BriefingSize.full,
            title: "Ho Chi Minh City",
            category: "Southern",
            imageUrl: "../assets/images/places/Saigon.jpg",
          ),
        ),
        //hardcode the remaining places
        const Briefing(
          size: BriefingSize.full,
          title: "Hanoi",
          category: "Northern",
          imageUrl: "../assets/images/places/Ha_Noi.jpg",
        ),
        const Briefing(
          size: BriefingSize.full,
          title: "Hue",
          category: "Central",
          imageUrl: "../assets/images/places/Hue.jpg",
        ),
        const Briefing(
          size: BriefingSize.full,
          title: "Da Nang",
          category: "Central",
          imageUrl: "../assets/images/places/Da_Nang.jpg",
        ),
      ],
    );
  }

  Widget _buildTopDestinations() {
    if (_isLoadingDestinations) {
      return Container(
        height: 320,
        alignment: Alignment.center,
        child: const CircularProgressIndicator(),
      );
    }

    if (_errorMessage != null || _topDestinations.isEmpty) {
      return Container(
        height: 320,
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.grey),
            const SizedBox(height: 8),
            Text(
              _errorMessage ?? 'No recommendations available',
              style: const TextStyle(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: _fetchTopDestinations,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    return VerticalBriefingCarousel(
      height: 320,
      autoPlay: true,
      items: _topDestinations.map((place) {
        // Extract first available category from tags
        List<String> category =
            ref.read(userSessionProvider)?.preferences ?? [];
        if (place.tags.isNotEmpty) {
          final firstTagList = place.tags;
          if (firstTagList.isNotEmpty) {
            category = firstTagList.keys.toList();
          }
        }

        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              CupertinoPageRoute(
                builder: (context) => PlaceOverview(place: place),
              ),
            );
          },
          child: Briefing(
            size: BriefingSize.vert,
            title: place.name,
            category: category.first,
            imageUrl: place.imageLink,
          ),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final eventsAsync = ref.watch(eventsProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Search field at the top
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    CupertinoPageRoute(
                      builder: (context) => const SearchScreen(),
                    ),
                  );
                },
                child: AbsorbPointer(
                  child: MyTextField(
                    textEditingController: _searchController,
                    label: "",
                    hintText: "Search for places...",
                    isSearchField: true,
                  ),
                ),
              ),
            ),

            // Scrollable content
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Events Banner Section
                    eventsAsync.when(
                      data: (events) => events.isNotEmpty
                          ? Column(
                              children: [
                                EventsBanner(events: events),
                                const SizedBox(height: 32),
                              ],
                            )
                          : const SizedBox.shrink(),
                      loading: () => const Padding(
                        padding: EdgeInsets.symmetric(vertical: 20),
                        child: CircularProgressIndicator(),
                      ),
                      error: (_, __) => const SizedBox.shrink(),
                    ),
                    const SizedBox(height: 16),
                    // Top Regions Section
                    const Padding(
                      padding: EdgeInsets.only(left: 20, top: 16),
                      child: Text(
                        "Top regions in Vietnam",
                        style: TextStyle(
                          fontSize: 24,
                          fontFamily: "BeVietnamPro",
                          fontWeight: FontWeight.w700,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildTopRegions(),
                    // Top Destinations Section
                    const Padding(
                      padding: EdgeInsets.only(left: 20, top: 16),
                      child: Text(
                        "Top destinations for you",
                        style: TextStyle(
                          fontSize: 24,
                          fontFamily: "BeVietnamPro",
                          fontWeight: FontWeight.w700,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildTopDestinations(),

                    const SizedBox(height: 32), // Bottom padding
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
