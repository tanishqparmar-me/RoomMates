import 'package:flutter/material.dart';
import 'package:roommates/onboarding/initial_roomate.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  bool isLastPage = false;

  final List<Widget> pages = [
    OnboardPage(
      title: "Track Roommate Expenses",
      points: [
        "Easily add shared expenses",
        "Track who paid and who owes",
        "Stay transparent with your friends",
      ],
    ),
    OnboardPage(
      title: "Smart Settlements",
      points: [
        "Auto-calculate balances",
        "Minimize paybacks",
        "Keep records clean and simple",
      ],
    ),
    OnboardPage(
      title: "Export & Share",
      points: [
        "Export reports as PDF",
        "Share expenses summary easily",
        "Accessible anytime, anywhere",
      ],
    ),
  ];

  void goToHome()async {
    if(!mounted)return;
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => InitialRoomate()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: pages.length,
                onPageChanged: (index) {
                  setState(() => isLastPage = index == pages.length - 1);
                },
                itemBuilder: (_, index) => pages[index],
              ),
            ),
            const SizedBox(height: 20),
            SmoothPageIndicator(
              controller: _controller,
              count: pages.length,
              effect: ExpandingDotsEffect(
                dotHeight: 6,
                dotWidth: 10,
                activeDotColor: Colors.amber.shade800,
              ),
            ),
            const SizedBox(height: 30),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: goToHome,
                    child: const Text("Skip"),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      if (isLastPage) {
                        goToHome();
                      } else {
                        _controller.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber.shade800,
                    ),
                    child: Text(isLastPage ? "Done" : "Next"),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}

class OnboardPage extends StatelessWidget {
  final String title;
  final List<String> points;

  const OnboardPage({
    super.key,
    required this.title,
    required this.points,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 50),
          Text(
            title,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 30),
          ...points.map((p) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle_outline, color: Colors.amber),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        p,
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}
