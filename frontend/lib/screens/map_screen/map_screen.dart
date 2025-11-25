import "package:flutter/material.dart";
import "package:flutter_map/flutter_map.dart";
import "package:latlong2/latlong.dart";
import "package:virtour_frontend/components/bottom_bar.dart";
import "package:virtour_frontend/components/briefings.dart";
import "package:virtour_frontend/screens/data factories/place.dart";
import "package:virtour_frontend/screens/data factories/filter_type.dart";

class MapScreen extends StatefulWidget {
  //default fallback
  Place place = Place(
    id: '1',
    name: 'Bà Thiên Hậu Pagoda',
    categories: ['Historical', 'Cultural'],
    imageUrl: 'assets/images/places/Ba_Thien_Hau.jpg',
    description:
        'Bà Thiên Hậu Pagoda is a historic temple located in Ho Chi Minh City, Vietnam. It is dedicated to the Chinese sea goddess Mazu and is known for its intricate architecture and cultural significance.',
    type: FilterType.historical,
    latitude: 10.7549,
    longitude: 106.6551,
    address:
        '710 Nguyễn Trãi, Phường 11, Quận 5, Thành phố Hồ Chí Minh, Vietnam',
  );

  MapScreen({
    super.key,
    required this.place,
  });

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController _mapController = MapController();

  @override
  Widget build(BuildContext context) {
    final LatLng location =
        LatLng(widget.place.latitude, widget.place.longitude);
    final name = widget.place.name;
    final address = widget.place.address;
    final imageUrl = widget.place.imageUrl;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Interactive OpenStreetMap
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: location,
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
                userAgentPackageName: 'com.cultour.app',
                maxZoom: 19,
                tileBuilder: (context, widget, tile) {
                  return widget;
                },
              ),
              // Marker for the pagoda location
              MarkerLayer(
                markers: [
                  Marker(
                    point: location,
                    width: 48,
                    height: 48,
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFD72323),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.25),
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

          Positioned(
            top: 48,
            left: (MediaQuery.of(context).size.width - 372) / 2,
            child: Briefing(
              size: BriefingSize.horiz,
              title: name,
              subtitle: address,
              imageUrl: imageUrl,
            ),
          ),
        ],
      ),
      bottomNavigationBar: const BottomNavBar(
        selectedIndex: 2,
      ),
    );
  }
}
