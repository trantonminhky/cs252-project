import "package:flutter/material.dart";
import "package:virtour_frontend/components/bottom_bar.dart";
import "package:virtour_frontend/components/briefings.dart";
import "package:virtour_frontend/components/custom_text_field.dart";
import "package:virtour_frontend/screens/map_screen/map_screen.dart";

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0; // Home is selected
  final TextEditingController _searchController = TextEditingController();

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    // Navigate based on selected index
    switch (index) {
      case 0: // Home - already here, do nothing
        break;
      case 1: // Trips
        // TODO: Navigate to Trips screen when created
        break;
      case 2: // Map
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MapScreen()),
        );
        break;
      case 3: // Profile
        // TODO: Navigate to Profile screen when created
        break;
    }
  }

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
                    SizedBox(
                      height: 320,
                      child: ListView(
                        physics: const BouncingScrollPhysics(),
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        children: const [
                          Briefing(
                            size: BriefingSize.vert,
                            title: "Sài Gòn",
                            category: "Văn hóa",
                            imageUrl: "../assets/images/places/Saigon.png",
                          ),
                          SizedBox(width: 16),
                          Briefing(
                            size: BriefingSize.vert,
                            title: "Hà Nội",
                            category: "Lịch sử",
                            imageUrl: "../assets/images/places/Ha_Noi.jpg",
                          ),
                          SizedBox(width: 16),
                          Briefing(
                            size: BriefingSize.vert,
                            title: "Đà Nẵng",
                            category: "Du lịch",
                            imageUrl: "../assets/images/places/Da_Nang.jpg",
                          ),
                          SizedBox(width: 16),
                          Briefing(
                            size: BriefingSize.vert,
                            title: "Huế",
                            category: "Di sản",
                            imageUrl: "../assets/images/places/Hue.jpg",
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
                    SizedBox(
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
      bottomNavigationBar: BottomNavBar(
        selectedIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
