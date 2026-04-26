import 'dart:async';
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
  Timer? _timeoutTimer;
  bool _isTimedOut = false;

  @override
  void initState() {
    super.initState();
    _signIn();
  }

  @override
  void dispose() {
    _timeoutTimer?.cancel();
    super.dispose();
  }

  void _signIn() {
    setState(() {
      _isTimedOut = false;
    });
    
    // Start a timeout timer to surface stalled requests
    _timeoutTimer?.cancel();
    _timeoutTimer = Timer(const Duration(seconds: 15), () {
      if (mounted && ref.read(authNotifierProvider).isLoading) {
        setState(() => _isTimedOut = true);
      }
    });

    Future.microtask(
      () => ref.read(authNotifierProvider.notifier).signInAsGuest(),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Listen to state changes to cancel timer
    ref.listen(authNotifierProvider, (previous, next) {
      if (!next.isLoading) {
        _timeoutTimer?.cancel();
        if (_isTimedOut) {
          setState(() => _isTimedOut = false);
        }
      }
    });

    final authState = ref.watch(authNotifierProvider);

    return Scaffold(
      backgroundColor: GameTheme.backgroundDark,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: _isTimedOut
              ? _ErrorView(
                  message: 'Connection is taking longer than expected. Please check your internet and try again.',
                  onRetry: _signIn,
                )
              : authState.when(
                  data: (_) => const CircularProgressIndicator(color: GameTheme.accentAmber),
                  loading: () => const CircularProgressIndicator(color: GameTheme.accentAmber),
                  error: (error, _) => _ErrorView(
                    message: 'Authentication failed. Please try again.',
                    onRetry: _signIn,
                  ),
                ),
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(
          Icons.error_outline_rounded,
          color: Colors.redAccent,
          size: 64,
        ),
        const SizedBox(height: 24),
        Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 16,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 32),
        ElevatedButton(
          onPressed: onRetry,
          style: ElevatedButton.styleFrom(
            backgroundColor: GameTheme.accentAmber,
            foregroundColor: GameTheme.backgroundDark,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: const Text(
            'Retry',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}
