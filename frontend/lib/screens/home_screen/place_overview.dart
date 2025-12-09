import "package:flutter/material.dart";
import "package:flutter/cupertino.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:virtour_frontend/components/briefings.dart";
import "package:virtour_frontend/frontend_service_layer/place_service.dart";
import "package:virtour_frontend/providers/review_provider.dart";
import "package:virtour_frontend/providers/user_info_provider.dart";
import "package:virtour_frontend/screens/data_factories/place.dart";
import "package:virtour_frontend/screens/home_screen/helpers.dart";
import "package:virtour_frontend/screens/home_screen/search_screen.dart";
import "package:virtour_frontend/providers/trip_provider.dart";
import "package:virtour_frontend/screens/data_factories/review.dart";
import "package:virtour_frontend/providers/selected_place_provider.dart";
import "package:virtour_frontend/providers/navigation_provider.dart";

class PlaceOverview extends ConsumerStatefulWidget {
  final Place place;

  const PlaceOverview({
    super.key,
    required this.place,
  });

  @override
  ConsumerState<PlaceOverview> createState() => _PlaceOverviewState();
}

class _PlaceOverviewState extends ConsumerState<PlaceOverview> {
  //late Future<List<Review>> _reviewsFuture;

  @override
  void initState() {
    super.initState();
    // Cache the future so it only executes once
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
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Back button
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                  child: IconButton(
                    icon: const Icon(CupertinoIcons.back, size: 32),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 16, horizontal: 16),
                    child: IconButton(
                      icon: const Icon(CupertinoIcons.heart, size: 32),
                      onPressed: () async {
                        final user = ref.read(userSessionProvider);
                        if (await RegionService().addSavedPlace(user!.userID, widget.place.id)) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content:
                                Text('${widget.place.name} added to Saved'),
                            duration: const Duration(seconds: 3),
                          ),
                        );
                            }
                        }                       
                      },
                    ))
              ]),
              const SizedBox(height: 24),
              // Full briefing with place information
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: SizedBox(
                  width: cardWidth,
                  height: briefingHeight,
                  child: Briefing(
                    size: BriefingSize.full,
                    title: widget.place.name,
                    category: 'place',
                    subtitle: '${widget.place.lat}, ${widget.place.lon}',
                    imageUrl: widget.place.imageLink,
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
                  itemCount:
                      widget.place.tags.values.expand((list) => list).length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final category = widget.place.tags.values
                        .expand((list) => list)
                        .elementAt(index);
                    final color = getCategoryColor(category);
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          CupertinoPageRoute(
                            builder: (context) => SearchScreen(
                              initialSelectedCategory: category,
                            ),
                          ),
                        );
                      },
                      child: Chip(
                        label: Text(
                          category,
                          style: const TextStyle(
                            fontFamily: "BeVietnamPro",
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                        backgroundColor: color,
                        side: BorderSide(
                          color: color,
                          width: 1,
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                    );
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
                    widget.place.description,
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
                  onPressed: () {
                    // Set the selected place for the map screen
                    ref
                        .read(selectedPlaceProvider.notifier)
                        .setPlace(widget.place);

                    // Pop to root and navigate to map via bottom bar
                    Navigator.of(context).popUntil((route) => route.isFirst);
                    ref.read(navigationProvider.notifier).setIndex(2);

                    // Show instruction snackbar
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                            'Please navigate to the map screen to view the location.'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
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
                    ref.read(tripProvider.notifier).addPlace(widget.place);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('${widget.place.name} added to Saves'),
                        duration: const Duration(seconds: 2),
                      ),
                    );
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
              ]),
              const SizedBox(height: 96),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  "Reviews",
                  style: TextStyle(
                    fontSize: 24,
                    fontFamily: "BeVietnamPro",
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              FutureBuilder<List<Review>>(
                future: ref.watch(reviewServiceProvider).getReviews(widget.place.name),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(20),
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }

                  if (snapshot.hasError) {
                    return Padding(
                      padding: const EdgeInsets.all(20),
                      child: Text(
                        'Error loading reviews: ${snapshot.error}',
                        style: const TextStyle(color: Colors.red),
                      ),
                    );
                  }

                  final reviews = snapshot.data ?? [];

                  if (reviews.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.all(20),
                      child: Text(
                        'No reviews yet',
                        style: TextStyle(
                          fontSize: 14,
                          fontFamily: "BeVietnamPro",
                          color: Colors.grey,
                        ),
                      ),
                    );
                  }

                  return ListView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: reviews.length,
                    itemBuilder: (context, index) {
                      final review = reviews[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const CircleAvatar(
                                  radius: 20,
                                  backgroundColor: Colors.grey,
                                  child: Icon(
                                    Icons.person,
                                    size: 24,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  review.username,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontFamily: "BeVietnamPro",
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              review.content,
                              style: const TextStyle(
                                fontSize: 14,
                                fontFamily: "BeVietnamPro",
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
