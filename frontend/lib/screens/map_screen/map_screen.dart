import "package:flutter/cupertino.dart";
import "package:flutter/material.dart";
import "package:flutter_map/flutter_map.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:latlong2/latlong.dart";
import "package:virtour_frontend/providers/geocode_provider.dart";
import "package:virtour_frontend/providers/selected_place_provider.dart";
import "package:virtour_frontend/providers/trip_provider.dart";
import "package:virtour_frontend/providers/user_info_provider.dart";
import "package:virtour_frontend/screens/data_factories/place.dart";
import "package:virtour_frontend/screens/home_screen/place_overview.dart";
import "package:virtour_frontend/frontend_service_layer/map_service.dart";
import "package:virtour_frontend/frontend_service_layer/location_service.dart";

class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({super.key});

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> {
  final MapController _mapController = MapController();

  // User location state
  LatLng? _userLocation;
  bool _isLoadingLocation = true;
  String? _locationError;

  // Default fallback location (District 1, HCMC)
  final LatLng _defaultLocation = const LatLng(10.7629, 106.6820);

  String _locationSubtitle = 'Loading address...';
  bool _isLoadingAddress = false;

  // Route state
  List<LatLng> _routePoints = [];
  bool _isLoadingRoute = false;
  String? _routeDistance;
  String? _routeDuration;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();

    final initialPlace = ref.read(selectedPlaceProvider);
    if (initialPlace != null) {
      _fetchAddress(initialPlace.lat, initialPlace.lon);
    }
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoadingLocation = true;
      _locationError = null;
    });

    try {
      final locationService = LocationService();
      final location = await locationService.getCurrentLocation();

      if (!mounted) return;

      if (location != null) {
        setState(() {
          _userLocation = location;
          _isLoadingLocation = false;
        });

        // Center map on user location if no place is selected
        final selectedPlace = ref.read(selectedPlaceProvider);
        if (selectedPlace == null) {
          _safeMapMove(location, 15.0);
        }
      } else {
        setState(() {
          _userLocation = _defaultLocation;
          _isLoadingLocation = false;
          _locationError =
              'Location permission denied. Using default location.';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _userLocation = _defaultLocation;
          _isLoadingLocation = false;
          _locationError = 'Failed to get location: ${e.toString()}';
        });
      }
    }
  }

  Future<void> _fetchAddress(double lat, double lon) async {
    if (_isLoadingAddress) return;

    setState(() => _isLoadingAddress = true);

    try {
      final geocodeService = ref.read(geocodeServiceProvider);
      final address = await geocodeService.reverseGeocode(lat, lon);

      if (!mounted) return;

      setState(() {
        _locationSubtitle = address ?? '$lat, $lon';
        _isLoadingAddress = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _locationSubtitle = '$lat, $lon';
        _isLoadingAddress = false;
      });
    }
  }

  Future<void> _showRoute(Place place) async {
    // If route is already shown, clear it
    if (_routePoints.isNotEmpty) {
      setState(() {
        _routePoints = [];
        _routeDistance = null;
        _routeDuration = null;
      });
      return;
    }

    // Check if user location is available
    if (_userLocation == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'Unable to get your location. Please enable location services.'),
            duration: Duration(seconds: 3),
          ),
        );
      }
      return;
    }

    // Get user info for token
    final userInfo = ref.read(userSessionProvider);
    if (userInfo == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please log in to see routes'),
            duration: Duration(seconds: 2),
          ),
        );
      }
      return;
    }

    setState(() {
      _isLoadingRoute = true;
    });

    try {
      final mapService = MapService();
      final routeResult = await mapService.getRoute(
        from: _userLocation!,
        to: LatLng(place.lat, place.lon),
        token: userInfo.userSessionToken,
        profile: 'driving-car',
      );

      if (!mounted) return;

      setState(() {
        _routePoints = routeResult.points;
        _routeDistance = routeResult.formattedDistance;
        _routeDuration = routeResult.formattedDuration;
        _isLoadingRoute = false;
      });

      // Adjust map bounds to show the entire route
      if (_routePoints.isNotEmpty) {
        final bounds = LatLngBounds.fromPoints(_routePoints);
        _mapController.fitCamera(
          CameraFit.bounds(
            bounds: bounds,
            padding: const EdgeInsets.only(
                top: 50, 
                left: 50, 
                right: 50, 
                bottom: 320 // Large bottom padding to clear the overlay
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingRoute = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to get route: ${e.toString()}'),
            duration: const Duration(seconds: 3),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _safeMapMove(LatLng dest, double zoom, {double bottomPadding = 0}) {
    try {
      // fitCamera is more powerful than move(). 
      // It allows us to define "padding" which shifts the center.
      _mapController.fitCamera(
        CameraFit.coordinates(
          coordinates: [dest], 
          padding: EdgeInsets.only(
            bottom: bottomPadding, // This pushes the center point UP
            top: 50,               // Slight top buffer
            left: 50, 
            right: 50
          ),
          maxZoom: zoom, // Force the camera to this zoom level
          minZoom: zoom, // Lock it so it doesn't zoom out too far
        ),
      );
    } catch (e) {
      // Fallback if map isn't ready, though fitCamera is usually robust
      try {
         _mapController.move(dest, zoom);
      } catch (_) {}
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<Place?>(selectedPlaceProvider, (previous, next) {
      if (next != null) {
        // 1. Move map to new place with OFFSET (300px bottom padding)
        _safeMapMove(LatLng(next.lat, next.lon), 15.0, bottomPadding: 300);
        
        _fetchAddress(next.lat, next.lon);

        if (previous?.id != next.id) {
          setState(() {
            _routePoints = [];
            _routeDistance = null;
            _routeDuration = null;
          });
        }
      } else if (_userLocation != null) {
        // 2. If deselected, center on user with NO OFFSET (0 padding)
        _safeMapMove(_userLocation!, 15.0);
      }
    });

    final selectedPlace = ref.watch(selectedPlaceProvider);

    final initialCenter = selectedPlace != null
        ? LatLng(selectedPlace.lat, selectedPlace.lon)
        : (_userLocation ?? _defaultLocation);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Interactive OpenStreetMap
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: initialCenter,
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
              // Route polyline layer
              if (_routePoints.isNotEmpty)
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: _routePoints,
                      color: const Color(0xFFD72323),
                      strokeWidth: 4.0,
                    ),
                  ],
                ),

              // Markers
              MarkerLayer(
                key: ValueKey(selectedPlace?.id ?? 'no-place'),
                markers: [
                  // User location marker
                  if (_userLocation != null)
                    Marker(
                      point: _userLocation!,
                      width: 40,
                      height: 40,
                      child: Container(
                        decoration: BoxDecoration(
                          color: _isLoadingLocation ? Colors.grey : Colors.blue,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 3),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Icon(
                          _isLoadingLocation
                              ? Icons.location_searching
                              : Icons.person,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                    ),
                  // Selected place marker
                  if (selectedPlace != null)
                    Marker(
                      point: LatLng(selectedPlace.lat, selectedPlace.lon),
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

          // Location error banner
          if (_locationError != null)
            Positioned(
              top: 48,
              left: 80,
              right: 16,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.orange,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const Icon(Icons.warning, color: Colors.white, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _locationError!,
                        style:
                            const TextStyle(color: Colors.white, fontSize: 12),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.refresh,
                          color: Colors.white, size: 20),
                      onPressed: _getCurrentLocation,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ),
            ),

          // Bottom overlay - only show when place is selected
          if (selectedPlace != null)
            _buildBottomOverlay(context, selectedPlace),
        ],
      ),
    );
  }

  Widget _buildBottomOverlay(BuildContext context, Place place) {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 16,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Content
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Place image
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      place.imageLink,
                      height: 160,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: 160,
                          color: Colors.grey[200],
                          child:
                              const Icon(Icons.image_not_supported, size: 48),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Place name
                  Text(
                    place.name,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Address/subtitle
                  Row(
                    children: [
                      Icon(Icons.location_on,
                          size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          _locationSubtitle,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // Distance info
                  if (_routeDistance != null && _routeDuration != null)
                    Row(
                      children: [
                        Icon(Icons.directions_car,
                            size: 16, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(
                          '$_routeDistance • $_routeDuration',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    )
                  else
                    Row(
                      children: [
                        Icon(Icons.directions_walk,
                            size: 16, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(
                          'Tap "Show Route" to see distance',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),

                  const SizedBox(height: 20),

                  // Action buttons
                  Row(
                    children: [
                      // Route button (primary)
                      Expanded(
                        flex: 2,
                        child: ElevatedButton.icon(
                          onPressed:
                              _isLoadingRoute ? null : () => _showRoute(place),
                          icon: _isLoadingRoute
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : Icon(
                                  _routePoints.isEmpty
                                      ? Icons.directions
                                      : Icons.clear,
                                  size: 20,
                                ),
                          label: Text(
                            _routePoints.isEmpty ? 'Show Route' : 'Clear Route',
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFD72323),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(width: 12),

                      // Save button
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: const Color(0xFFD72323)),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: IconButton(
                          onPressed: () {
                            ref.read(tripProvider.notifier).addPlace(place);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Save place successfully!'),
                                duration: Duration(seconds: 2),
                              ),
                            );
                          },
                          icon: const Icon(Icons.bookmark_border),
                          color: const Color(0xFFD72323),
                        ),
                      ),

                      const SizedBox(width: 12),

                      // More info button
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: const Color(0xFFD72323)),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: IconButton(
                          onPressed: () {
                            Navigator.of(context).push(
                              CupertinoPageRoute(
                                builder: (context) {
                                  return PlaceOverview(place: place);
                                },
                              ),
                            );
                          },
                          icon: const Icon(Icons.info_outline),
                          color: const Color(0xFFD72323),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
