import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:poker_gambit/core/config/app_config.dart';
import 'package:poker_gambit/core/localization/locale_provider.dart';
import 'package:poker_gambit/core/theme/game_theme.dart';
import 'package:poker_gambit/core/widgets/auto_guest_sign_in.dart';
import 'package:poker_gambit/core/widgets/splash_screen.dart';
import 'package:poker_gambit/features/auth/presentation/providers/auth_provider.dart';
import 'package:poker_gambit/features/menu/presentation/screens/main_menu_screen.dart';
import 'package:poker_gambit/features/menu/presentation/screens/onboarding_screen.dart';
import 'package:poker_gambit/l10n/app_localizations.dart';

class CardGameApp extends ConsumerWidget {
  final bool hasSeenOnboarding;

  const CardGameApp({super.key, required this.hasSeenOnboarding});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: AppConfig.appName,
      debugShowCheckedModeBanner: false,
      theme: GameTheme.darkTheme,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      locale: ref.watch(localeStateProvider),
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
