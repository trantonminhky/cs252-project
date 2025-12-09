import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';

// Base class for all briefing carousels
abstract class BriefingCarousel extends StatefulWidget {
  final List<Widget> items;
  final double height;
  final bool autoPlay;
  final bool enableInfiniteScroll;

  const BriefingCarousel({
    super.key,
    required this.items,
    required this.height,
    this.autoPlay = false,
    this.enableInfiniteScroll = true,
  });
}

// Base state class with common functionality
abstract class BriefingCarouselState<T extends BriefingCarousel>
    extends State<T> {
  int currentIndex = 0;
  final CarouselSliderController controller = CarouselSliderController();

  // Subclasses must override to provide specific carousel options
  double get viewportFraction;
  bool get enlargeCenterPage;
  double? get enlargeFactor;
  bool get padEnds;

  @override
  Widget build(BuildContext context) {
    final options = CarouselOptions(
      height: widget.height,
      viewportFraction: viewportFraction,
      enlargeCenterPage: enlargeCenterPage,
      padEnds: padEnds,
      autoPlay: widget.autoPlay,
      autoPlayInterval: const Duration(seconds: 3),
      autoPlayAnimationDuration: const Duration(milliseconds: 800),
      autoPlayCurve: Curves.fastOutSlowIn,
      enableInfiniteScroll: widget.enableInfiniteScroll,
      scrollDirection: Axis.horizontal,
      onPageChanged: (index, reason) {
        setState(() {
          currentIndex = index;
        });
      },
    );

    return Column(
      children: [
        CarouselSlider(
          carouselController: controller,
          options: enlargeFactor != null
              ? options.copyWith(enlargeFactor: enlargeFactor)
              : options,
          items: widget.items,
        ),
        const SizedBox(height: 16),
        _buildIndicators(),
      ],
    );
  }

  Widget _buildIndicators() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: widget.items.asMap().entries.map((entry) {
        return GestureDetector(
          onTap: () => controller.animateToPage(entry.key),
          child: Container(
            width: currentIndex == entry.key ? 24.0 : 8.0,
            height: 8.0,
            margin:
                EdgeInsets.symmetric(horizontal: enlargeCenterPage ? 4.0 : 8.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4.0),
              color: currentIndex == entry.key
                  ? const Color(0xFFD72323)
                  : Colors.grey[400],
            ),
          ),
        );
      }).toList(),
    );
  }
}

// Horizontal Briefing Carousel
class HorizontalBriefingCarousel extends BriefingCarousel {
  const HorizontalBriefingCarousel({
    super.key,
    required super.items,
    required super.height,
    super.autoPlay,
    super.enableInfiniteScroll,
  });

  @override
  State<HorizontalBriefingCarousel> createState() =>
      _HorizontalBriefingCarouselState();
}

class _HorizontalBriefingCarouselState
    extends BriefingCarouselState<HorizontalBriefingCarousel> {
  @override
  double get viewportFraction => 0.95;

  @override
  bool get enlargeCenterPage => false;

  @override
  double? get enlargeFactor => null;

  @override
  bool get padEnds => false;
}

// Vertical Briefing Carousel
class VerticalBriefingCarousel extends BriefingCarousel {
  const VerticalBriefingCarousel({
    super.key,
    required super.items,
    required super.height,
    super.autoPlay,
    super.enableInfiniteScroll,
  });

  @override
  State<VerticalBriefingCarousel> createState() =>
      _VerticalBriefingCarouselState();
}

class _VerticalBriefingCarouselState
    extends BriefingCarouselState<VerticalBriefingCarousel> {
  @override
  double get viewportFraction => 0.5;

  @override
  bool get enlargeCenterPage => true;

  @override
  double? get enlargeFactor => 0.2;

  @override
  bool get padEnds => false;
}

// Full Briefing Carousel
class FullBriefingCarousel extends BriefingCarousel {
  const FullBriefingCarousel({
    super.key,
    required super.items,
    required super.height,
    super.autoPlay,
    super.enableInfiniteScroll,
  });

  @override
  State<FullBriefingCarousel> createState() => _FullBriefingCarouselState();
}

class _FullBriefingCarouselState
    extends BriefingCarouselState<FullBriefingCarousel> {
  @override
  double get viewportFraction => 1.0;

  @override
  bool get enlargeCenterPage => false;

  @override
  double? get enlargeFactor => null;

  @override
  bool get padEnds => false;
}
