import "package:flutter/material.dart";
import "package:flutter_map/flutter_map.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:latlong2/latlong.dart";
import "package:virtour_frontend/components/briefings.dart";
import "package:virtour_frontend/frontend_service_layer/geocode_service.dart";
import "package:virtour_frontend/providers/selected_place_provider.dart";

class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({super.key});

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> {
  final MapController _mapController = MapController();
  final GeocodeService _geocodeService = GeocodeService();

  // Default location (Bà Thiên Hậu Pagoda)
  late LatLng _location;
  late String _locationName;
  String _locationSubtitle = 'Loading address...';
  late String _locationImage;
  bool _isLoadingAddress = false;

  @override
  void initState() {
    super.initState();
    _fetchAddress();
  }

  @override
  void didUpdateWidget(MapScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    _fetchAddress();
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
              initialZoom: 10.0,
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
                maxZoom: 19,
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

          // Horizontal briefing at the top (y = 48)
          Positioned(
            top: 48,
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
