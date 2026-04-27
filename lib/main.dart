import 'package:poker_gambit/app.dart';
import 'package:poker_gambit/core/config/app_initializer.dart';
import 'package:poker_gambit/features/menu/presentation/screens/onboarding_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppInitializer.initialize();
  final hasSeenOnboarding = await OnboardingScreen.hasSeenOnboarding();
  runApp(
    ProviderScope(child: CardGameApp(hasSeenOnboarding: hasSeenOnboarding)),
  );
}
