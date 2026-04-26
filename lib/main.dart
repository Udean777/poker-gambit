import 'package:card_games/core/config/app_config.dart';
import 'package:card_games/core/config/app_initializer.dart';
import 'package:card_games/core/theme/game_theme.dart';
import 'package:card_games/core/widgets/auto_guest_sign_in.dart';
import 'package:card_games/core/widgets/splash_screen.dart';
import 'package:card_games/features/auth/presentation/providers/auth_provider.dart';
import 'package:card_games/features/menu/presentation/screens/main_menu_screen.dart';
import 'package:card_games/features/menu/presentation/screens/onboarding_screen.dart';
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

class CardGameApp extends ConsumerWidget {
  final bool hasSeenOnboarding;

  const CardGameApp({super.key, required this.hasSeenOnboarding});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: AppConfig.appName,
      debugShowCheckedModeBanner: false,
      theme: GameTheme.darkTheme,
      home: ref
          .watch(authStateProvider)
          .when(
            loading: () => const SplashScreen(),
            error: (_, _) => const SplashScreen(),
            data: (user) => user == null
                ? const AutoGuestSignIn()
                : hasSeenOnboarding
                ? const MainMenuScreen()
                : const OnboardingScreen(),
          ),
    );
  }
}
