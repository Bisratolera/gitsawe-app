import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/l10n/strings.dart';
import '../core/theme/app_theme.dart';
import '../services/app_settings.dart';
import '../services/daily_refresh.dart';
import '../services/notification_service.dart';
import 'today_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingData> _pages = const [
    OnboardingData(titleKey: 'onb1_title', descKey: 'onb1_desc', image: 'assets/images/onboard1.png'),
    OnboardingData(titleKey: 'onb2_title', descKey: 'onb2_desc', image: 'assets/images/onboard2.png'),
    OnboardingData(titleKey: 'onb3_title', descKey: 'onb3_desc', image: 'assets/images/onboard3.png'),
  ];

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_completed', true);

    // Ask for notification permission now (not at first launch) so the user
    // understands why, then schedule the daily reminders.
    if (AppSettings.instance.notificationsEnabled) {
      final granted = await NotificationService.instance.requestPermission();
      if (!granted && NotificationService.instance.supportsRuntimePermission) {
        await AppSettings.instance.setNotificationsEnabled(false);
      }
      await DailyRefresh.instance.syncReminders();
    }
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const TodayScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.maroon,
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: _pages.length,
            onPageChanged: (int page) {
              setState(() {
                _currentPage = page;
              });
            },
            itemBuilder: (context, index) {
              return _OnboardingPage(data: _pages[index]);
            },
          ),
          Positioned(
            bottom: 60,
            left: 0,
            right: 0,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    _pages.length,
                    (index) => _buildDot(index),
                  ),
                ),
                const SizedBox(height: 32),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        if (_currentPage == _pages.length - 1) {
                          _completeOnboarding();
                        } else {
                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeIn,
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: AppColors.maroon,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        tr(context, _currentPage == _pages.length - 1 ? 'start' : 'next'),
                        style: const TextStyle(fontSize: 18),
                      ),
                    ),
                  ),
                ),
                TextButton(
                  onPressed: _completeOnboarding,
                  child: Text(
                    tr(context, 'skip'),
                    style: const TextStyle(color: Colors.white70),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDot(int index) {
    return Container(
      height: 10,
      width: _currentPage == index ? 24 : 10,
      margin: const EdgeInsets.only(right: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        color: _currentPage == index ? Colors.white : Colors.white30,
      ),
    );
  }
}

class OnboardingData {
  final String titleKey;
  final String descKey;
  final String image;

  const OnboardingData({
    required this.titleKey,
    required this.descKey,
    required this.image,
  });
}

class _OnboardingPage extends StatelessWidget {
  final OnboardingData data;

  const _OnboardingPage({required this.data});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(40, 40, 40, 220),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(data.image, height: 200),
          const SizedBox(height: 40),
          Text(
            tr(context, data.titleKey),
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          Text(
            tr(context, data.descKey),
            style: const TextStyle(
              fontSize: 16,
              color: Colors.white,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
      ),
    );
  }
}
