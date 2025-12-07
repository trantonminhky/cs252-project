import "package:flutter/material.dart";
import "package:flutter/cupertino.dart";
import "package:flutter_map/flutter_map.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:latlong2/latlong.dart";
import "package:virtour_frontend/components/briefings.dart";
import "package:virtour_frontend/frontend_service_layer/geocode_service.dart";
import "package:virtour_frontend/providers/selected_place_provider.dart";
import "package:virtour_frontend/providers/navigation_provider.dart";

class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({super.key});

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> {
  final MapController _mapController = MapController();
  final GeocodeService _geocodeService = GeocodeService();
  final TextEditingController _searchController = TextEditingController();

  // Default location (Bà Thiên Hậu Pagoda)
  late LatLng _location;
  late String _locationName;
  String _locationSubtitle = 'Loading address...';
  late String _locationImage;
  bool _isLoadingAddress = false;
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _fetchAddress();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(MapScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    _fetchAddress();
  }

  Future<void> _searchLocation(String query) async {
    if (query.trim().isEmpty) return;

    setState(() {
      _isSearching = true;
    });

    try {
      final place = await _geocodeService.geocodeAddress(query);

      if (place != null && mounted) {
        setState(() {
          _location = LatLng(place.lat, place.lon);
          _locationName = place.name;
          _locationImage = place.imageLink;
          _locationSubtitle = '${place.lat}, ${place.lon}';
          _isSearching = false;
        });

        // Move map to new location
        _mapController.move(_location, 15.0);

        // Fetch proper address
        _fetchAddressForLocation(place.lat, place.lon);
      } else {
        setState(() {
          _isSearching = false;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location not found')),
          );
        }
      }
    } catch (e) {
      setState(() {
        _isSearching = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Future<void> _fetchAddressForLocation(double lat, double lon) async {
    try {
      final address = await _geocodeService.reverseGeocode(lat, lon);
      if (mounted) {
        setState(() {
          _locationSubtitle = address ?? '$lat, $lon';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _locationSubtitle = '$lat, $lon';
        });
      }
    }
  }

  Future<void> _fetchAddress() async {
    final selectedPlace = ref.read(selectedPlaceProvider);

    if (selectedPlace != null && !_isLoadingAddress) {
      setState(() {
        _isLoadingAddress = true;
      });

      try {
        final address = await _geocodeService.reverseGeocode(
          selectedPlace.lat,
          selectedPlace.lon,
        );

        if (mounted) {
          setState(() {
            _locationSubtitle =
                address ?? '${selectedPlace.lat}, ${selectedPlace.lon}';
            _isLoadingAddress = false;
          });
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _locationSubtitle = '${selectedPlace.lat}, ${selectedPlace.lon}';
            _isLoadingAddress = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedPlace = ref.watch(selectedPlaceProvider);

    // Use selected place if provided, otherwise use default
    if (selectedPlace != null) {
      _location = LatLng(selectedPlace.lat, selectedPlace.lon);
      _locationName = selectedPlace.name;
      _locationImage = selectedPlace.imageLink;
    } else {
      _location = const LatLng(10.7549, 106.6551);
      _locationName = 'Bà Thiên Hậu Pagoda';
      _locationSubtitle =
          '710 Nguyễn Trãi, Phường 11, Quận 5, Thành phố Hồ Chí Minh, Vietnam';
      _locationImage = 'assets/images/places/Ba_Thien_Hau.jpg';
    }
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Interactive OpenStreetMap
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _location,
              initialZoom: 15.0,
              minZoom: 5.0,
              maxZoom: 18.0,
              interactionOptions: const InteractionOptions(
                flags: InteractiveFlag.all,
              ),
            ),
            children: [
              // OpenStreetMap tile layer
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.virtour.app',
                maxZoom: 19.0,
                tileBuilder: (context, widget, tile) {
                  return widget;
                },
              ),
              // Marker for the pagoda location
              MarkerLayer(
                markers: [
                  Marker(
                    point: _location,
                    width: 48,
                    height: 48,
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFD72323),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.location_on,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),

          // Back button at top left
          Positioned(
            top: 16,
            left: 16,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black),
                onPressed: () {
                  ref.read(navigationProvider.notifier).setIndex(0);
                },
              ),
            ),
          ),

          // Search bar
          Positioned(
            top: 16,
            left: 72,
            right: 16,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                textInputAction: TextInputAction.search,
                onChanged: (value) {
                  setState(() {}); // Rebuild to show/hide clear button
                },
                onSubmitted: (value) {
                  _searchLocation(value);
                },
                decoration: InputDecoration(
                  hintText: "Search for a location...",
                  hintStyle: TextStyle(
                    color: Colors.grey[400],
                    fontFamily: "BeVietnamPro",
                    fontWeight: FontWeight.w400,
                  ),
                  prefixIcon: _isSearching
                      ? const Padding(
                          padding: EdgeInsets.all(12.0),
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        )
                      : const Icon(CupertinoIcons.search),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderSide: BorderSide.none,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide.none,
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
                            });
                          },
                        )
                      : null,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 96),
          Positioned(
            top: 72,
            left: (MediaQuery.of(context).size.width - 372) / 2,
            child: Briefing(
              size: BriefingSize.horiz,
              title: _locationName,
              subtitle: _locationSubtitle,
              imageUrl: _locationImage,
            ),
          ),
        ],
      ),
    );
  }
}
