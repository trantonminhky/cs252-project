import "package:flutter/material.dart";
import "package:flutter_map/flutter_map.dart";
import "package:latlong2/latlong.dart";
import "package:virtour_frontend/components/briefings.dart";
import "package:virtour_frontend/screens/data_factories/place.dart";

class MapScreen extends StatefulWidget {
  final Place? place;

  const MapScreen({super.key, this.place});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController _mapController = MapController();

  // Default location (Bà Thiên Hậu Pagoda)
  late LatLng _location;
  late String _locationName;
  late String _locationSubtitle;
  late String _locationImage;

  @override
  void initState() {
    super.initState();
    // Use place data if provided, otherwise use default
    if (widget.place != null) {
      _location = LatLng(widget.place!.lat, widget.place!.lon);
      _locationName = widget.place!.name;
      _locationSubtitle = widget.place!.address;
      _locationImage = widget.place!.imageLink;
    } else {
      _location = const LatLng(10.7549, 106.6551);
      _locationName = 'Bà Thiên Hậu Pagoda';
      _locationSubtitle =
          '710 Nguyễn Trãi, Phường 11, Quận 5, Thành phố Hồ Chí Minh, Vietnam';
      _locationImage = 'assets/images/places/Ba_Thien_Hau.jpg';
    }
  }

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
