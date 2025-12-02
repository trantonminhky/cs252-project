import "package:flutter/cupertino.dart";
import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:virtour_frontend/components/briefings.dart";
import "package:virtour_frontend/components/custom_text_field.dart";
import "package:virtour_frontend/components/events_banner.dart";
import "package:virtour_frontend/components/briefing_carousel.dart";
import "package:virtour_frontend/screens/home_screen/region_overview.dart";
import "package:virtour_frontend/screens/home_screen/search_screen.dart";
import "package:virtour_frontend/screens/data_factories/filter_type.dart";
import "package:virtour_frontend/providers/event_provider.dart";
import "package:virtour_frontend/screens/data_factories/region.dart";
import "package:virtour_frontend/screens/data_factories/data_service.dart";

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  final RegionService _regionService = RegionService();

  List<Region> _topRegions = [];
  bool _isLoadingRegions = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchTopRegions();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchTopRegions() async {
    setState(() {
      _isLoadingRegions = true;
      _errorMessage = null;
    });

    try {
      final regions = <Region>[];
      final regionIds = [
        'sg',
      ];

      for (final id in regionIds) {
        try {
          final region = await _regionService.getRegionbyId(id);
          regions.add(region);
        } catch (e) {
          print('Error fetching region $id: $e');
        }
      }

      setState(() {
        _topRegions = regions;
        _isLoadingRegions = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load regions: $e';
        _isLoadingRegions = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load regions: $e')),
        );
      }
    }
  }

  Widget _buildTopDestinations() {
    if (_isLoadingRegions) {
      return Container(
        height: 320,
        alignment: Alignment.center,
        child: const CircularProgressIndicator(),
      );
    }

    if (_errorMessage != null || _topRegions.isEmpty) {
      return Container(
        height: 320,
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.grey),
            const SizedBox(height: 8),
            Text(
              _errorMessage ?? 'No regions available',
              style: const TextStyle(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: _fetchTopRegions,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    return VerticalBriefingCarousel(
      height: 320,
      autoPlay: true,
      items: _topRegions.map((region) {
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              CupertinoPageRoute(
                builder: (context) => RegionOverview(
                  region: region,
                  currentFilter: FilterType.regionOverview,
                ),
              ),
            );
          },
          child: Briefing(
            size: BriefingSize.vert,
            title: region.name,
            category: "Văn hóa",
            imageUrl: region.imageUrl,
          ),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final events = ref.watch(eventsProvider);

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
                    if (events.isNotEmpty) ...[
                      EventsBanner(events: events),
                      const SizedBox(height: 32),
                    ],

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

                    const SizedBox(height: 32),

                    // Previously Viewed Section
                    const Padding(
                      padding: EdgeInsets.only(left: 20),
                      child: Text(
                        "Previously Viewed",
                        style: TextStyle(
                          fontSize: 24,
                          fontFamily: "BeVietnamPro",
                          fontWeight: FontWeight.w700,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const HorizontalBriefingCarousel(
                      height: 187,
                      autoPlay: false,
                      items: [
                        Briefing(
                          size: BriefingSize.horiz,
                          title: "Bà Thiên Hậu Pagoda",
                          subtitle: "710 Nguyễn Trãi, Quận 5",
                          imageUrl: "../assets/images/places/Ba_Thien_Hau.jpg",
                        ),
                        Briefing(
                          size: BriefingSize.horiz,
                          title: "Notre-Dame Cathedral",
                          subtitle: "Quận 1, TP.HCM",
                          imageUrl:
                              "../assets/images/places/Notre_Dame_Cathedral.jpg",
                        ),
                        Briefing(
                          size: BriefingSize.horiz,
                          title: "Hanoi Railway",
                          subtitle: "Old Quarter, Hà Nội",
                          imageUrl: "../assets/images/places/Hanoi_rail.jpg",
                        ),
                      ],
                    ),

                    const SizedBox(height: 32),

                    // Cultour Essentials in Sài Gòn Section
                    const Padding(
                      padding: EdgeInsets.only(left: 20),
                      child: Text(
                        "Cultour Essentials in Sài Gòn",
                        style: TextStyle(
                          fontSize: 24,
                          fontFamily: "BeVietnamPro",
                          fontWeight: FontWeight.w700,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const VerticalBriefingCarousel(
                      height: 320,
                      autoPlay: false,
                      items: [
                        Briefing(
                          size: BriefingSize.vert,
                          title: "Saigon Opera House",
                          category: "Kiến trúc",
                          imageUrl:
                              "../assets/images/places/Saigon_Opera_House.jpg",
                        ),
                        Briefing(
                          size: BriefingSize.vert,
                          title: "Central Post Office",
                          category: "Lịch sử",
                          imageUrl:
                              "../assets/images/places/Saigon_Central_Post_Office.jpg",
                        ),
                        Briefing(
                          size: BriefingSize.vert,
                          title: "Việt Nam Quốc Tự",
                          category: "Di sản",
                          imageUrl:
                              "../assets/images/places/Viet_Nam_Quoc_Tu.jpg",
                        ),
                        Briefing(
                          size: BriefingSize.vert,
                          title: "Bà Thiên Hậu Pagoda",
                          category: "Tâm linh",
                          imageUrl: "../assets/images/places/Ba_Thien_Hau.jpg",
                        ),
                      ],
                    ),

                    const SizedBox(height: 20), // Bottom padding
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
