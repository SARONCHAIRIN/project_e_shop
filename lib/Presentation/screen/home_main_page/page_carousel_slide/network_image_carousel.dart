import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class NetworkImageCarousel extends StatefulWidget {
  const NetworkImageCarousel({super.key});

  @override
  State<NetworkImageCarousel> createState() => _NetworkImageCarouselState();
}

class _NetworkImageCarouselState extends State<NetworkImageCarousel> {
  int activeIndex = 0;

  final List<String> imageUrls = [
    'https://via.placeholder.com/800x400/3498db/ffffff?text=Sale+50%25',
    'https://via.placeholder.com/800x400/e74c3c/ffffff?text=New+Arrivals',
    'https://via.placeholder.com/800x400/2ecc71/ffffff?text=Free+Shipping',
    'https://via.placeholder.com/800x400/f39c12/ffffff?text=Flash+Sale',
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CarouselSlider.builder(
          itemCount: imageUrls.length,
          options: CarouselOptions(
            height: 200,
            autoPlay: true,
            autoPlayInterval: const Duration(seconds: 3),
            autoPlayAnimationDuration: const Duration(milliseconds: 800),
            pauseAutoPlayOnTouch: true,
            viewportFraction: 1.0,
            enlargeCenterPage: false,
            onPageChanged: (index, reason) {
              setState(() {
                activeIndex = index;
              });
            },
          ),
          itemBuilder: (context, index, realIndex) {
            return Container(
              width: double.infinity,
              margin: const EdgeInsets.symmetric(horizontal: 5),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                image: DecorationImage(
                  image: NetworkImage(imageUrls[index]),
                  fit: BoxFit.fill,
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 16),
        AnimatedSmoothIndicator(
          activeIndex: activeIndex,
          count: imageUrls.length,
          effect: const ExpandingDotsEffect(
            dotWidth: 8,
            dotHeight: 8,
            activeDotColor: Colors.blue,
            dotColor: Colors.grey,
          ),
        ),
      ],
    );
  }
}