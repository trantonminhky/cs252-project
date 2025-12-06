import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';

// Horizontal Briefing Carousel
class HorizontalBriefingCarousel extends StatefulWidget {
  final List<Widget> items;
  final double height;
  final bool autoPlay;
  final bool enableInfiniteScroll;

  const HorizontalBriefingCarousel({
    super.key,
    required this.items,
    required this.height,
    this.autoPlay = false,
    this.enableInfiniteScroll = true,
  });

  @override
  State<HorizontalBriefingCarousel> createState() =>
      _HorizontalBriefingCarouselState();
}

class _HorizontalBriefingCarouselState
    extends State<HorizontalBriefingCarousel> {
  int _currentIndex = 0;
  final CarouselSliderController _controller = CarouselSliderController();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CarouselSlider(
          carouselController: _controller,
          options: CarouselOptions(
            height: widget.height,
            viewportFraction: 0.95,
            enlargeCenterPage: false,
            padEnds: false,
            autoPlay: widget.autoPlay,
            autoPlayInterval: const Duration(seconds: 3),
            autoPlayAnimationDuration: const Duration(milliseconds: 800),
            autoPlayCurve: Curves.fastOutSlowIn,
            enableInfiniteScroll: widget.enableInfiniteScroll,
            scrollDirection: Axis.horizontal,
            onPageChanged: (index, reason) {
              setState(() {
                _currentIndex = index;
              });
            },
          ),
          items: widget.items,
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: widget.items.asMap().entries.map((entry) {
            return GestureDetector(
              onTap: () => _controller.animateToPage(entry.key),
              child: Container(
                width: _currentIndex == entry.key ? 24.0 : 8.0,
                height: 8.0,
                margin: const EdgeInsets.symmetric(horizontal: 8.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4.0),
                  color: _currentIndex == entry.key
                      ? const Color(0xFFD72323)
                      : Colors.grey[400],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

// Vertical Briefing Carousel
class VerticalBriefingCarousel extends StatefulWidget {
  final List<Widget> items;
  final double height;
  final bool autoPlay;
  final bool enableInfiniteScroll;

  const VerticalBriefingCarousel({
    super.key,
    required this.items,
    required this.height,
    this.autoPlay = false,
    this.enableInfiniteScroll = true,
  });

  @override
  State<VerticalBriefingCarousel> createState() =>
      _VerticalBriefingCarouselState();
}

class _VerticalBriefingCarouselState extends State<VerticalBriefingCarousel> {
  int _currentIndex = 0;
  final CarouselSliderController _controller = CarouselSliderController();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CarouselSlider(
          carouselController: _controller,
          options: CarouselOptions(
            height: widget.height,
            viewportFraction: 0.5,
            enlargeCenterPage: true,
            enlargeFactor: 0.2,
            autoPlay: widget.autoPlay,
            autoPlayInterval: const Duration(seconds: 3),
            autoPlayAnimationDuration: const Duration(milliseconds: 800),
            autoPlayCurve: Curves.fastOutSlowIn,
            enableInfiniteScroll: widget.enableInfiniteScroll,
            scrollDirection: Axis.horizontal,
            onPageChanged: (index, reason) {
              setState(() {
                _currentIndex = index;
              });
            },
          ),
          items: widget.items,
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: widget.items.asMap().entries.map((entry) {
            return GestureDetector(
              onTap: () => _controller.animateToPage(entry.key),
              child: Container(
                width: _currentIndex == entry.key ? 24.0 : 8.0,
                height: 8.0,
                margin: const EdgeInsets.symmetric(horizontal: 4.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4.0),
                  color: _currentIndex == entry.key
                      ? const Color(0xFFD72323)
                      : Colors.grey[400],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

// Legacy class for backward compatibility
class BriefingCarousel extends HorizontalBriefingCarousel {
  const BriefingCarousel({
    super.key,
    required super.items,
    required super.height,
    super.autoPlay,
    super.enableInfiniteScroll,
  });
}
