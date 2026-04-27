import 'package:flutter/material.dart';
import 'package:poker_gambit/core/config/app_config.dart';

class OnboardingItem {
  final String title;
  final String description;
  final IconData icon;

  const OnboardingItem({
    required this.title,
    required this.description,
    required this.icon,
  });
}

List<OnboardingItem> onboardingData = [
  OnboardingItem(
    title: "Selamat Datang!",
    description:
        "Nikmati permainan kartu strategi ${AppConfig.appName} yang seru dan menantang.",
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
