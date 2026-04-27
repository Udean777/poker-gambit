import 'package:poker_gambit/core/theme/game_theme.dart';
import 'package:poker_gambit/core/widgets/app_scaffold.dart';
import 'package:poker_gambit/features/menu/domain/models/onboarding_item.dart';
import 'package:poker_gambit/features/menu/presentation/screens/main_menu_screen.dart';
import 'package:poker_gambit/features/menu/presentation/widgets/onboarding_widgets.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  static const _keyOnboardingSeen = 'onboarding_seen';

  static Future<bool> hasSeenOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyOnboardingSeen) ?? false;
  }

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      decoration: GameTheme.tableGradient,
      body: Column(
        children: [
          Align(
            alignment: Alignment.topRight,
            child: Padding(
              padding: const EdgeInsets.only(top: 8, right: 16),
              child: TextButton(
                onPressed: _markSeenAndNavigate,
                child: Text(
                  'Skip',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.5),
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (index) => setState(() => _currentPage = index),
              itemCount: onboardingData.length,
              itemBuilder: (context, index) =>
                  OnboardingSlide(item: onboardingData[index]),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 32.0,
              vertical: 40.0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: List.generate(
                    onboardingData.length,
                    (index) =>
                        OnboardingIndicator(isActive: index == _currentPage),
                  ),
                ),
                _buildActionButton(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton() {
    final isLastPage = _currentPage == onboardingData.length - 1;
    return ElevatedButton(
      onPressed: () async {
        if (!isLastPage) {
          _pageController.nextPage(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        } else {
          await _markSeenAndNavigate();
        }
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: GameTheme.accentAmber,
        foregroundColor: Colors.black,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        elevation: 8,
      ),
      child: Text(
        isLastPage ? "MULAI" : "LANJUT",
        style: Theme.of(
          context,
        ).textTheme.titleLarge?.copyWith(color: Colors.black, fontSize: 18),
      ),
    );
  }

  Future<void> _markSeenAndNavigate() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(OnboardingScreen._keyOnboardingSeen, true);
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MainMenuScreen()),
      );
    }
  }
}
