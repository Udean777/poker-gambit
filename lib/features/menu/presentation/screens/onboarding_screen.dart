import 'package:card_games/core/theme/game_theme.dart';
import 'package:card_games/core/widgets/app_scaffold.dart';
import 'package:card_games/features/menu/presentation/screens/main_menu_screen.dart';
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

  final List<OnboardingItem> _items = [
    OnboardingItem(
      title: "Selamat Datang!",
      description:
          "Nikmati permainan kartu strategi Poker Gambit yang seru dan menantang.",
      icon: Icons.style,
    ),
    OnboardingItem(
      title: "Aturan Main",
      description:
          "Susun strategi terbaikmu untuk mengalahkan lawan dengan kombinasi kartu yang tepat.",
      icon: Icons.psychology,
    ),
    OnboardingItem(
      title: "Lawan AI",
      description:
          "Uji kemampuanmu melawan AI yang cerdas sebelum bertanding dengan pemain lain.",
      icon: Icons.smart_toy,
    ),
  ];

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
                  onPageChanged: (index) {
                    setState(() {
                      _currentPage = index;
                    });
                  },
                  itemCount: _items.length,
                  itemBuilder: (context, index) {
                    return _buildPage(_items[index]);
                  },
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
                        _items.length,
                        (index) => _buildIndicator(index == _currentPage),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        if (_currentPage < _items.length - 1) {
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
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        elevation: 8,
                      ),
                      child: Text(
                        _currentPage == _items.length - 1 ? "Mulai" : "Lanjut",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
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

  Widget _buildPage(OnboardingItem item) {
    return Padding(
      padding: const EdgeInsets.all(40.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              shape: BoxShape.circle,
              border: Border.all(
                color: GameTheme.accentAmber.withValues(alpha: 0.5),
                width: 2,
              ),
            ),
            child: Icon(item.icon, size: 100, color: GameTheme.accentAmber),
          ),
          const SizedBox(height: 60),
          Text(
            item.title,
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          Text(
            item.description,
            style: TextStyle(
              fontSize: 18,
              color: Colors.white.withValues(alpha: 0.8),
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildIndicator(bool isActive) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      height: 8,
      width: isActive ? 24 : 8,
      decoration: BoxDecoration(
        color: isActive
            ? GameTheme.accentAmber
            : Colors.white.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}

class OnboardingItem {
  final String title;
  final String description;
  final IconData icon;

  OnboardingItem({
    required this.title,
    required this.description,
    required this.icon,
  });
}
