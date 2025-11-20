import "package:flutter/material.dart";
import "package:flutter/cupertino.dart";
import "package:virtour_frontend/components/bottom_bar.dart";
import "package:virtour_frontend/components/briefings.dart";
import "package:virtour_frontend/components/cards.dart";
import "package:virtour_frontend/screens/map_screen/map_screen.dart";
import "package:virtour_frontend/screens/home_screen/home_screen.dart";

class RegionOverview extends StatefulWidget {
  const RegionOverview({super.key});

  @override
  State<RegionOverview> createState() => _RegionOverviewState();
}

class _RegionOverviewState extends State<RegionOverview> {
  int _selectedIndex = 0; // Home is selected
  bool _isExpanded = false; // Track "Read More" state

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    // Navigate based on selected index
    switch (index) {
      case 0: // Home
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
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
              Padding(
                padding: const EdgeInsets.only(left: 10, top: 10),
                child: IconButton(
                  icon: const Icon(CupertinoIcons.back, size: 40),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              // Push content down by 24px
              const SizedBox(height: 24),
              // Full Briefing - scaled to match card width
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: SizedBox(
                  width: cardWidth,
                  height: briefingHeight,
                  child: const Briefing(
                    size: BriefingSize.full,
                    title: "Sai Gon",
                    category: "Region",
                    imageUrl: "assets/images/places/Saigon.png",
                  ),
                ),
              ),
              // Description section with grey background
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  width: cardWidth,
                  color: Colors.grey[100],
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _isExpanded
                            ? "Saigon is the former name of Ho Chi Minh City, one of the most attractive tourist destinations in Vietnam. The name Saigon has intrigued travelers for centuries with its blend of French colonial architecture, bustling markets, and vibrant street life. This dynamic metropolis offers visitors an unforgettable experience, from historic landmarks like the Notre Dame Cathedral and Independence Palace to the authentic flavors of Vietnamese cuisine found in every corner. Whether you're exploring the Cu Chi Tunnels, shopping at Ben Thanh Market, or simply watching life unfold from a sidewalk café, Saigon captivates with its energy and charm."
                            : "Saigon is the former name of Ho Chi Minh City, one of the most attractive tourist destinations in Vietnam. The name Saigon has intrigued travelers for centuries with its blend of French colonial architecture, bustling markets, and vibrant street life...",
                        style: const TextStyle(
                          fontSize: 14,
                          fontFamily: "BeVietnamPro",
                          color: Colors.black87,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _isExpanded = !_isExpanded;
                          });
                        },
                        child: Text(
                          _isExpanded ? "Read Less" : "Read More",
                          style: const TextStyle(
                            fontSize: 14,
                            fontFamily: "BeVietnamPro",
                            fontWeight: FontWeight.w600,
                            color: Color(0xffd72323),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // "Where to go?" heading - aligned left with briefing
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  "Where to go?",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                    fontFamily: "BeVietnamPro",
                    fontWeight: FontWeight.w700,
                    letterSpacing: -1,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Cards section - aligned left with briefing
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    Cards(
                      size: CardSize.list,
                      title: "Cu Chi Tunnels",
                      chips: [
                        (label: "Historical", backgroundColor: Colors.amber),
                        (label: "Top-rated", backgroundColor: Colors.red)
                      ],
                      imageUrl: "assets/images/places/Cu_Chi_Tunnel.jpg",
                    ),
                    SizedBox(height: 16),
                    Cards(
                      size: CardSize.list,
                      title: "Ben Thanh Market",
                      chips: [
                        (label: "Cultural", backgroundColor: Colors.amber),
                        (label: "Shopping", backgroundColor: Colors.blue),
                        (label: "Must-visit", backgroundColor: Colors.red)
                      ],
                      imageUrl: "assets/images/places/Ben_Thanh_Market.jpg",
                    ),
                    SizedBox(height: 16),
                    Cards(
                      size: CardSize.list,
                      title: "Independence Palace",
                      chips: [
                        (label: "Landmark", backgroundColor: Colors.amber),
                        (label: "Architecture", backgroundColor: Colors.red),
                      ],
                      imageUrl: "assets/images/places/Independence_Palace.jpg",
                    ),
                    SizedBox(height: 16),
                    Cards(
                      size: CardSize.list,
                      title: "Notre Dame Cathedral",
                      chips: [
                        (label: "Religious", backgroundColor: Colors.blue),
                        (label: "French Colonial", backgroundColor: Colors.red),
                      ],
                      imageUrl: "assets/images/places/Notre_Dame_Cathedral.jpg",
                    ),
                    SizedBox(height: 20),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavBar(
        selectedIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
