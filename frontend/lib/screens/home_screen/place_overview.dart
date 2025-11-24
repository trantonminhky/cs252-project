import "package:flutter/material.dart";
import "package:flutter/cupertino.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:virtour_frontend/components/briefings.dart";
import "package:virtour_frontend/screens/data_factories/place.dart";
import "package:virtour_frontend/screens/home_screen/helpers.dart";
import "package:virtour_frontend/providers/trip_provider.dart";

class PlaceOverview extends ConsumerWidget {
  final Place place;

  const PlaceOverview({super.key, required this.place});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
        child: SingleChildScrollView(
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
              // Full briefing with place information
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: SizedBox(
                  width: cardWidth,
                  height: briefingHeight,
                  child: Briefing(
                    size: BriefingSize.full,
                    title: place.name,
                    category: place.type.name.toUpperCase(),
                    subtitle: place.address,
                    imageUrl: place.imageUrl,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Category filter chips
              SizedBox(
                height: 50,
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  scrollDirection: Axis.horizontal,
                  itemCount: place.categories.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    return buildCategoryChip(place.categories[index]);
                  },
                ),
              ),
              const SizedBox(height: 20),
              // Place description
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  width: cardWidth,
                  color: Colors.grey[100],
                  padding: const EdgeInsets.all(20),
                  child: Text(
                    place.description,
                    style: const TextStyle(
                      fontSize: 14,
                      fontFamily: "BeVietnamPro",
                      color: Colors.black87,
                      height: 1.5,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 48),
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                TextButton(
                  onPressed: () {},
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    side: const BorderSide(color: Colors.black, width: 2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    "View on map",
                    style: TextStyle(
                      color: Color(0xffd72323),
                      fontSize: 20,
                      fontFamily: "BeVietnamPro",
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                ),
                TextButton(
                  onPressed: () {
                    ref.read(tripProvider.notifier).addPlace(place);
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: const Color(0xffd72323),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(13),
                    ),
                  ),
                  child: const Text(
                    "Add to trip",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontFamily: "BeVietnamPro",
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ])
            ],
          ),
        ),
      ),
    );
  }
}
