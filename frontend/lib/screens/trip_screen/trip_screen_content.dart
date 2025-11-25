import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:virtour_frontend/providers/trip_provider.dart';

class TripScreenContent extends ConsumerStatefulWidget {
  const TripScreenContent({super.key});

  @override
  ConsumerState<TripScreenContent> createState() => _TripScreenContentState();
}

class _TripScreenContentState extends ConsumerState<TripScreenContent>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final places = ref.watch(tripProvider);
    final placesList = places.toList();

    return Column(
      children: [
        const SizedBox(height: 23),
        Center(
          child: Container(
            height: 40,
            width: 310,
            decoration: BoxDecoration(
              color: const Color(0xffe2e0e0),
              borderRadius: BorderRadius.circular(500),
            ),
            child: TabBar(
              controller: _tabController,
              dividerColor: Colors.transparent,
              indicator: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(500),
                border: Border.all(
                  color: Colors.black,
                  width: 2,
                  strokeAlign: BorderSide.strokeAlignInside,
                ),
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              tabs: const [
                Tab(
                  child: SizedBox(
                    height: 32,
                    width: 131,
                    child: Center(
                      child: Text(
                        "Saves",
                        style: TextStyle(
                          color: Color(0xff1e1e1e),
                          fontSize: 15,
                          fontFamily: "BeVietnamPro",
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ),
                ),
                Tab(
                  child: SizedBox(
                    height: 32,
                    width: 131,
                    child: Center(
                      child: Text(
                        "Itinerary",
                        style: TextStyle(
                          color: Color(0xff1e1e1e),
                          fontSize: 15,
                          fontFamily: "BeVietnamPro",
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              // Saves tab
              placesList.isEmpty
                  ? const Center(
                      child: Text(
                        'No places saved yet',
                        style: TextStyle(
                          fontSize: 16,
                          fontFamily: "BeVietnamPro",
                        ),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 8),
                      itemCount: placesList.length,
                      itemBuilder: (context, index) {
                        final place = placesList[index];
                        return Dismissible(
                          key: Key(place.name + place.address),
                          direction: DismissDirection.endToStart,
                          onDismissed: (direction) {
                            ref.read(tripProvider.notifier).removePlace(place);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('${place.name} removed'),
                                duration: const Duration(seconds: 2),
                              ),
                            );
                          },
                          background: Container(
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 20),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.delete,
                              color: Colors.white,
                              size: 32,
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: SizedBox(
                                    width: double.infinity,
                                    height: 100,
                                    // should be Image.network once data is ready
                                    child: Image.asset(
                                      place.imageUrl,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                        return Container(
                                          color: Colors.grey[300],
                                          child: const Icon(
                                            Icons.image_not_supported,
                                            size: 40,
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 7),
                                Text(
                                  place.name,
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 16,
                                    fontFamily: "BeVietnamPro",
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 7),
                                Text(
                                  place.address,
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 12,
                                    fontFamily: "BeVietnamPro",
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
              // Itinerary tab (temporary version)
              Padding(
                padding: const EdgeInsets.only(
                  left: 83,
                  right: 83,
                  top: 47,
                  bottom: 520,
                ),
                child: TextButton(
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      side: const BorderSide(
                        color: Colors.black,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(13),
                    ),
                  ),
                  onPressed: () {},
                  child: const SizedBox(
                    width: 245,
                    height: 52,
                    child: Center(
                      child: Text(
                        "Add new itinerary",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 20,
                          fontFamily: "BeVietnamPro",
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
