import 'dart:async';
import 'package:flutter/material.dart';

class CarouselSlider extends StatefulWidget {
  const CarouselSlider({super.key});

  @override
  State<CarouselSlider> createState() => _CarouselSliderState();
}

class _CarouselSliderState extends State<CarouselSlider> {
  final List<String> _imagePaths = [
    "assets/images/map1.png",
    "assets/images/map2.png",
    "assets/images/map3.png",
  ];

  int _currentIndex = 0;
  late final List<Widget> _images;
  late final PageController _controller;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _controller = PageController(initialPage: 0);
    _images = List.generate(_imagePaths.length, (index) {
      return Image.asset(_imagePaths[index], fit: BoxFit.cover);
    });
    _timer = Timer.periodic(Duration(seconds: 3), (timer) {
      if (_controller.page == _imagePaths.length - 1) {
        _controller.animateToPage(
          0,
          duration: Duration(milliseconds: 500),
          curve: Curves.easeIn,
        );
      } else {
        _controller.nextPage(
          duration: Duration(milliseconds: 500),
          curve: Curves.easeIn,
        );
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: SizedBox(
            width: double.infinity,
            height: 400,
            child: PageView.builder(
              controller: _controller,
              itemCount: _images.length,
              onPageChanged: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              itemBuilder: (context, index) {
                return _images[index];
              },
            ),
          ),
        ),
        SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(_imagePaths.length, (index) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: InkWell(
                onTap: () {
                  _controller.animateToPage(
                    index,
                    duration: Duration(milliseconds: 300),
                    curve: Curves.easeIn,
                  );
                },
                child: CircleAvatar(
                  backgroundColor: index == _currentIndex
                      ? Color(0xffFFFBCC)
                      : Color(0xffffffff),
                  radius: 10,
                ),
              ),
            );
          }),
        ),
      ],
    );
  }
}
