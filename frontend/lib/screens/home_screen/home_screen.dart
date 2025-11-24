import "package:flutter/cupertino.dart";
import "package:flutter/material.dart";
import "package:virtour_frontend/components/briefings.dart";
import "package:virtour_frontend/components/custom_text_field.dart";
import "package:virtour_frontend/screens/home_screen/region_overview.dart";
import "package:virtour_frontend/screens/data_factories/filter_type.dart";

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Search field at the top
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: MyTextField(
                textEditingController: _searchController,
                label: "",
                hintText: "Search for places...",
                isSearchField: true,
              ),
            ),

            // Scrollable content
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top Destinations Section
                    const Padding(
                      padding: EdgeInsets.only(left: 20, top: 16),
                      child: Text(
                        "Top Destinations",
                        style: TextStyle(
                          fontSize: 24,
                          fontFamily: "BeVietnamPro",
                          fontWeight: FontWeight.w700,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      color: Colors.transparent,
                      height: 320,
                      child: ListView(
                        physics: const BouncingScrollPhysics(),
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        children: [
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                CupertinoPageRoute(
                                  //this is mock data, hooking up with db later
                                  builder: (context) => const RegionOverview(
                                    regionId: "01",
                                    regionName: "Sài Gòn",
                                    currentFilter: FilterType.regionOverview,
                                  ),
                                ),
                              );
                            },
                            child: const Briefing(
                              size: BriefingSize.vert,
                              title: "Sài Gòn",
                              category: "Văn hóa",
                              imageUrl: "../assets/images/places/Saigon.png",
                            ),
                          ),
                          const SizedBox(width: 16),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                CupertinoPageRoute(
                                  builder: (context) => const RegionOverview(
                                    regionId: "01",
                                    regionName: "Sài Gòn",
                                    currentFilter: FilterType.regionOverview,
                                  ),
                                ),
                              );
                            },
                            child: const Briefing(
                              size: BriefingSize.vert,
                              title: "Hà Nội",
                              category: "Lịch sử",
                              imageUrl: "../assets/images/places/Ha_Noi.jpg",
                            ),
                          ),
                          const SizedBox(width: 16),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                CupertinoPageRoute(
                                  builder: (context) => const RegionOverview(
                                    regionId: "01",
                                    regionName: "Sài Gòn",
                                    currentFilter: FilterType.regionOverview,
                                  ),
                                ),
                              );
                            },
                            child: const Briefing(
                              size: BriefingSize.vert,
                              title: "Đà Nẵng",
                              category: "Du lịch",
                              imageUrl: "../assets/images/places/Da_Nang.jpg",
                            ),
                          ),
                          const SizedBox(width: 16),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                CupertinoPageRoute(
                                  builder: (context) => const RegionOverview(
                                    regionId: "01",
                                    regionName: "Sài Gòn",
                                    currentFilter: FilterType.regionOverview,
                                  ),
                                ),
                              );
                            },
                            child: const Briefing(
                              size: BriefingSize.vert,
                              title: "Huế",
                              category: "Di sản",
                              imageUrl: "../assets/images/places/Hue.jpg",
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Previously Viewed Section
                    const Padding(
                      padding: EdgeInsets.only(left: 20),
                      child: Text(
                        "Previously Viewed",
                        style: TextStyle(
                          fontSize: 24,
                          fontFamily: "BeVietnamPro",
                          fontWeight: FontWeight.w700,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 187,
                      child: ListView(
                        physics: const BouncingScrollPhysics(),
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        children: const [
                          Briefing(
                            size: BriefingSize.horiz,
                            title: "Bà Thiên Hậu Pagoda",
                            subtitle: "710 Nguyễn Trãi, Quận 5",
                            imageUrl:
                                "../assets/images/places/Ba_Thien_Hau.jpg",
                          ),
                          SizedBox(width: 16),
                          Briefing(
                            size: BriefingSize.horiz,
                            title: "Notre-Dame Cathedral",
                            subtitle: "Quận 1, TP.HCM",
                            imageUrl:
                                "../assets/images/places/Notre_Dame_Cathedral.jpg",
                          ),
                          SizedBox(width: 16),
                          Briefing(
                            size: BriefingSize.horiz,
                            title: "Hanoi Railway",
                            subtitle: "Old Quarter, Hà Nội",
                            imageUrl: "../assets/images/places/Hanoi_rail.jpg",
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Cultour Essentials in Sài Gòn Section
                    const Padding(
                      padding: EdgeInsets.only(left: 20),
                      child: Text(
                        "Cultour Essentials in Sài Gòn",
                        style: TextStyle(
                          fontSize: 24,
                          fontFamily: "BeVietnamPro",
                          fontWeight: FontWeight.w700,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      color: Colors.transparent,
                      height: 320,
                      child: ListView(
                        physics: const BouncingScrollPhysics(),
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        children: const [
                          Briefing(
                            size: BriefingSize.vert,
                            title: "Saigon Opera House",
                            category: "Kiến trúc",
                            imageUrl:
                                "../assets/images/places/Saigon_Opera_House.jpg",
                          ),
                          SizedBox(width: 16),
                          Briefing(
                            size: BriefingSize.vert,
                            title: "Central Post Office",
                            category: "Lịch sử",
                            imageUrl:
                                "../assets/images/places/Saigon_Central_Post_Office.jpg",
                          ),
                          SizedBox(width: 16),
                          Briefing(
                            size: BriefingSize.vert,
                            title: "Việt Nam Quốc Tự",
                            category: "Di sản",
                            imageUrl:
                                "../assets/images/places/Viet_Nam_Quoc_Tu.jpg",
                          ),
                          SizedBox(width: 16),
                          Briefing(
                            size: BriefingSize.vert,
                            title: "Bà Thiên Hậu Pagoda",
                            category: "Tâm linh",
                            imageUrl:
                                "../assets/images/places/Ba_Thien_Hau.jpg",
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20), // Bottom padding
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
