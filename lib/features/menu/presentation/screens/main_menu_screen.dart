import 'dart:io';

import 'package:card_games/core/theme/game_theme.dart';
import 'package:card_games/features/game/presentation/screens/game_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MainMenuScreen extends StatelessWidget {
  const MainMenuScreen({super.key});

  void _showComingSoon(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text(
          "Coming soon!",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: GameTheme.accentAmber,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: GameTheme.tableGradient,
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Title/Logo
                    const Icon(
                      Icons.style,
                      size: 80,
                      color: GameTheme.accentAmber,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "POKER GAMBIT",
                      style: Theme.of(context).textTheme.headlineLarge
                          ?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 4,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      height: 2,
                      width: 100,
                      color: GameTheme.accentAmber,
                    ),
                    const SizedBox(height: 60),

                    // Menu Buttons
                    _MenuButton(
                      label: "VS AI",
                      icon: Icons.smart_toy,
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const GameScreen(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    _MenuButton(
                      label: "VS PLAYER",
                      icon: Icons.person,
                      isLocked: true,
                      onPressed: () => _showComingSoon(context),
                    ),
                    const SizedBox(height: 16),
                    _MenuButton(
                      label: "MULTIPLAYER",
                      icon: Icons.groups,
                      isLocked: true,
                      onPressed: () => _showComingSoon(context),
                    ),
                    const SizedBox(height: 16),
                    _MenuButton(
                      label: "QUIT GAME",
                      icon: Icons.exit_to_app,
                      isQuit: true,
                      onPressed: () {
                        if (Platform.isAndroid || Platform.isIOS) {
                          SystemNavigator.pop();
                        } else {
                          exit(0);
                        }
                      },
                    ),

                    const SizedBox(height: 40),
                    Text(
                      "v1.0.0",
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.5),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _MenuButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onPressed;
  final bool isLocked;
  final bool isQuit;

  const _MenuButton({
    required this.label,
    required this.icon,
    required this.onPressed,
    this.isLocked = false,
    this.isQuit = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxWidth: 300),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: isQuit
              ? Colors.red.withValues(alpha: 0.2)
              : Colors.white.withValues(alpha: 0.1),
          foregroundColor: isQuit ? Colors.redAccent : Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 20),
          side: BorderSide(
            color: isLocked
                ? Colors.white10
                : (isQuit
                      ? Colors.redAccent.withValues(alpha: 0.5)
                      : GameTheme.accentAmber.withValues(alpha: 0.5)),
            width: 1.5,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          elevation: 0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 24),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
                color: isLocked
                    ? Colors.white.withValues(alpha: 0.3)
                    : (isQuit ? Colors.redAccent : Colors.white),
              ),
            ),
            if (isLocked) ...[
              const SizedBox(width: 8),
              Icon(
                Icons.lock,
                size: 16,
                color: Colors.white.withValues(alpha: 0.3),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
