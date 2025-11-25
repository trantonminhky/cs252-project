import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:virtour_frontend/providers/regions_visited_provider.dart';
import 'package:virtour_frontend/screens/profile_screen/visited_places_page.dart';

class RegionProgressPage extends ConsumerWidget {
  const RegionProgressPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final regions = ref.watch(regionsVisitedProvider);
    final regionsList = regions.toList();

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              Transform.translate(
                offset: const Offset(-15, 0),
                child: IconButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  icon: const Icon(CupertinoIcons.back, size: 40),
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                "Visited Regions",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 30,
                  fontFamily: "BeVietnamPro",
                  fontWeight: FontWeight.w700,
                  height: 1,
                  letterSpacing: -1,
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: regionsList.length,
                  itemBuilder: (context, index) {
                    final region = regionsList[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 19.0),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(
                            CupertinoPageRoute(builder: (context) {
                              return const VisitedPlacesPage();
                            }),
                          );
                        },
                        child: SizedBox(
                          width: 372,
                          height: 167,
                          child: Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: SizedBox(
                                  width: double.infinity,
                                  height: 167,
                                  // should be Image.network once data is ready
                                  child: Image.asset(
                                    region.imageUrl,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              Align(
                                alignment: Alignment.bottomLeft,
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    region.name,
                                    style: const TextStyle(
                                      color: Color(0xfff6f6f6),
                                      fontSize: 44,
                                      fontFamily: "Oswald",
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
