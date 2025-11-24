import 'package:flutter_svg/flutter_svg.dart';

import 'package:flutter/material.dart';
import 'package:sakkeny_app/pages/sign_up.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();

  int _currentPage = 0;

  final List<OnboardingData> _pages = [
    OnboardingData(
      title: 'Find\nthe perfect\nplace',

      description: 'Post your requirements\nand highly relevant\nmatches.',

      imagePath: 'assets/images/onboarding1.svg',
    ),

    OnboardingData(
      title: 'Browse for\nthe trusted\nfeelings',

      description:
          'Explore verified properties with\nclear details and real photos.',

      imagePath: 'assets/images/onboarding2.svg',
    ),

    OnboardingData(
      title: 'Start\nyour journey\nwith us',

      description: 'Chat with owners or agents\nand book your visit in seconds',

      imagePath: 'assets/images/onboarding3.svg',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            if (_currentPage < _pages.length - 1)
              Padding(
                padding: const EdgeInsets.only(top: 10, right: 20),

                child: Align(
                  alignment: Alignment.centerRight,

                  child: TextButton(
                    onPressed: () {
                      _pageController.animateToPage(
                        _pages.length - 1,

                        duration: const Duration(milliseconds: 300),

                        curve: Curves.easeInOut,
                      );
                    },

                    child: const Text(
                      'Skip',

                      style: TextStyle(color: Color(0xFF276152), fontSize: 16),
                    ),
                  ),
                ),
              ),

            Expanded(
              child: PageView.builder(
                controller: _pageController,

                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },

                itemCount: _pages.length,

                itemBuilder: (context, index) {
                  return OnboardingPage(data: _pages[index]);
                },
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(32),

              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,

                children: [
                  Row(
                    children: List.generate(
                      _pages.length,

                      (index) => Container(
                        margin: const EdgeInsets.only(right: 8),

                        width: index == _currentPage ? 24 : 8,

                        height: 8,

                        decoration: BoxDecoration(
                          color: index == _currentPage
                              ? const Color(0xFF276152)
                              : Colors.grey[300],

                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),

                  GestureDetector(
                    onTap: () {
                      if (_currentPage < _pages.length - 1) {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 300),

                          curve: Curves.easeInOut,
                        );
                      } else {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (context) => const SignUpPage(),
                          ),
                        );
                      }
                    },

                    child: Container(
                      width: 56,

                      height: 56,

                      decoration: const BoxDecoration(
                        color: Color(0xFF276152),

                        shape: BoxShape.circle,
                      ),

                      child: const Icon(
                        Icons.arrow_forward,

                        color: Colors.white,

                        size: 24,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class OnboardingPage extends StatelessWidget {
  final OnboardingData data;

  const OnboardingPage({Key? key, required this.data}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final horizontalPadding = 32.0;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          const SizedBox(height: 20),

          Expanded(
            flex: 5,

            child: SvgPicture.asset(
              data.imagePath,

              fit: BoxFit.contain,

              width: double.infinity,
            ),
          ),

          const SizedBox(height: 24),

          Expanded(
            flex: 3,

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                Text(
                  data.title,

                  style: const TextStyle(
                    fontSize: 32,

                    fontWeight: FontWeight.bold,

                    height: 1.05,
                  ),
                ),

                const SizedBox(height: 12),

                Text(
                  data.description,

                  style: TextStyle(
                    fontSize: 16,

                    color: Colors.grey[600],

                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class OnboardingData {
  final String title;

  final String description;

  final String imagePath;

  OnboardingData({
    required this.title,

    required this.description,

    required this.imagePath,
  });
}
