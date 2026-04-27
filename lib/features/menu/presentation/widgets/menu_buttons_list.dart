import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:poker_gambit/features/game/presentation/screens/game_screen.dart';
import 'package:poker_gambit/features/leaderboard/presentation/screens/leaderboard_screen.dart';
import 'package:poker_gambit/features/menu/presentation/screens/card_gallery_screen.dart';
import 'package:poker_gambit/features/menu/presentation/widgets/menu_button.dart';
import 'package:poker_gambit/features/settings/presentation/screens/settings_screen.dart';
import 'package:poker_gambit/l10n/app_localizations.dart';

class MenuButtonsList extends StatelessWidget {
  final bool isOnline;
  final Function(String) onShowSnackbar;

  const MenuButtonsList({
    super.key,
    required this.isOnline,
    required this.onShowSnackbar,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    const gap = SizedBox(height: 12);

    return Column(
      children: [
        MenuButton(
          label: l10n.vsAi,
          icon: Icons.smart_toy,
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const GameScreen()),
          ),
        ),
        gap,
        MenuButton(
          label: l10n.vsPlayer,
          icon: Icons.person,
          isLocked: true,
          onPressed: () => onShowSnackbar(l10n.comingSoon),
        ),
        gap,
        MenuButton(
          label: l10n.leaderboard,
          icon: Icons.emoji_events,
          isLocked: !isOnline,
          onPressed: !isOnline
              ? () => onShowSnackbar(l10n.offlineLeaderboard)
              : () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const LeaderboardScreen()),
                ),
        ),
        gap,
        MenuButton(
          label: l10n.multiplayer,
          icon: Icons.groups,
          isLocked: true,
          onPressed: () => onShowSnackbar(l10n.comingSoon),
        ),
        gap,
        MenuButton(
          label: l10n.cardCombos,
          icon: Icons.style,
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CardGalleryScreen()),
          ),
        ),
        gap,
        MenuButton(
          label: l10n.settings,
          icon: Icons.settings,
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const SettingsScreen()),
          ),
        ),
        const SizedBox(height: 24),
        MenuButton(
          label: l10n.quitGame,
          icon: Icons.exit_to_app,
          isQuit: true,
          onPressed: () => _handleQuit(context),
        ),
      ],
    );
  }

  void _handleQuit(BuildContext context) {
    if (kIsWeb) return;
    if (Platform.isAndroid || Platform.isIOS) {
      SystemNavigator.pop();
    } else {
      exit(0);
    }
  }
}
