import 'package:card_games/core/theme/game_theme.dart';
import 'package:card_games/features/auth/presentation/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AutoGuestSignIn extends ConsumerStatefulWidget {
  const AutoGuestSignIn({super.key});

  @override
  ConsumerState<AutoGuestSignIn> createState() => _AutoGuestSignInState();
}

class _AutoGuestSignInState extends ConsumerState<AutoGuestSignIn> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref.read(authNotifierProvider.notifier).signInAsGuest(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: GameTheme.backgroundDark,
      body: Center(
        child: CircularProgressIndicator(color: GameTheme.accentAmber),
      ),
    );
  }
}
