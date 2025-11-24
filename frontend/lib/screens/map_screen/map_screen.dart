import "package:flutter/material.dart";
import "package:flutter_map/flutter_map.dart";
import "package:latlong2/latlong.dart";
import "package:virtour_frontend/components/briefings.dart";

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController _mapController = MapController();

  // Bà Thiên Hậu Pagoda coordinates (example location)
  final LatLng _pagodaLocation = const LatLng(10.7549, 106.6551);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Interactive OpenStreetMap
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _pagodaLocation,
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
                    point: _pagodaLocation,
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
            child: const Briefing(
              size: BriefingSize.horiz,
              title: 'Bà Thiên Hậu Pagoda',
              subtitle:
                  '710 Nguyễn Trãi, Phường 11, Quận 5, Thành phố Hồ Chí Minh, Vietnam',
              imageUrl: 'assets/images/places/Ba_Thien_Hau.jpg',
            ),
          ),
        ],
      ),
    );
  }
}
