import 'dart:io';
import 'package:flutter/foundation.dart';

import 'package:card_games/core/providers/connectivity_provider.dart';
import 'package:card_games/core/theme/game_theme.dart';
import 'package:card_games/core/widgets/app_scaffold.dart';
import 'package:card_games/features/auth/presentation/providers/auth_provider.dart';
import 'package:card_games/features/auth/presentation/widgets/profile_bottom_sheet.dart';
import 'package:card_games/features/auth/presentation/widgets/user_avatar_widget.dart';
import 'package:card_games/features/game/presentation/screens/game_screen.dart';
import 'package:card_games/features/leaderboard/presentation/screens/leaderboard_screen.dart';
import 'package:card_games/features/menu/presentation/widgets/login_banner.dart';
import 'package:card_games/features/menu/presentation/widgets/menu_button.dart';
import 'package:card_games/features/menu/presentation/widgets/menu_logo.dart';
import 'package:card_games/features/menu/presentation/screens/card_gallery_screen.dart';
import 'package:card_games/features/menu/presentation/widgets/sync_indicator.dart';
import 'package:card_games/core/services/image_precache_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MainMenuScreen extends ConsumerStatefulWidget {
  const MainMenuScreen({super.key});

  @override
  ConsumerState<MainMenuScreen> createState() => _MainMenuScreenState();
}

class _MainMenuScreenState extends ConsumerState<MainMenuScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));
    _controller.forward();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ImagePrecacheService.precacheAllCards(context);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authAsync = ref.watch(authStateProvider);
    final isOnline = ref.watch(connectivityProvider).valueOrNull ?? false;
    final user = authAsync.valueOrNull;
    final isGuest = user?.isGuest ?? true;

    return AppScaffold(
      decoration: GameTheme.tableGradient,
      body: Stack(
        children: [
          FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: SizedBox(
                height: MediaQuery.of(context).size.height,
                child: SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: MediaQuery.of(context).size.height,
                    ),
                    child: IntrinsicHeight(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(24, 56, 24, 32),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const MenuLogo(),
                            const SizedBox(height: 24),
                            if (isGuest) ...[
                              LoginBanner(
                                onTap: () => ProfileBottomSheet.show(context),
                                isLoading: authAsync.isLoading,
                              ),
                              const SizedBox(height: 16),
                            ],
                            const Spacer(),
                            ..._buildMenuButtons(context, isOnline),
                            const Spacer(),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: 12,
            left: 16,
            right: 16,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (user != null)
                  UserAvatarWidget(
                    user: user,
                    onTap: () => ProfileBottomSheet.show(context),
                  ),
                SyncIndicator(isOnline: isOnline),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildMenuButtons(BuildContext context, bool isOnline) {
    const gap = SizedBox(height: 12);
    return [
      MenuButton(
        label: 'VS AI',
        icon: Icons.smart_toy,
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const GameScreen()),
        ),
      ),
      gap,
      MenuButton(
        label: 'VS PLAYER',
        icon: Icons.person,
        isLocked: true,
        onPressed: () => _showComingSoon(context),
      ),
      gap,
      MenuButton(
        label: 'LEADERBOARD',
        icon: Icons.emoji_events,
        isLocked: !isOnline,
        onPressed: !isOnline
            ? () => _showOfflineSnackbar(context)
            : () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const LeaderboardScreen()),
              ),
      ),
      gap,
      MenuButton(
        label: 'MULTIPLAYER',
        icon: Icons.groups,
        isLocked: true,
        onPressed: () => _showComingSoon(context),
      ),
      gap,
      MenuButton(
        label: 'CARD COLLECTION',
        icon: Icons.style,
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const CardGalleryScreen()),
        ),
      ),
      const SizedBox(height: 24),
      MenuButton(
        label: 'QUIT GAME',
        icon: Icons.exit_to_app,
        isQuit: true,
        onPressed: () {
          if (kIsWeb) {
            // On web, we can't easily exit the app, so we can either do nothing
            // or show a message. For now, we'll just return.
            return;
          }
          if (Platform.isAndroid || Platform.isIOS) {
            SystemNavigator.pop();
          } else {
            exit(0);
          }
        },
      ),
    ];
  }

  void _showComingSoon(BuildContext context) =>
      _showSnackbar(context, 'Coming soon!');

  void _showOfflineSnackbar(BuildContext context) =>
      _showSnackbar(context, 'Leaderboard tidak tersedia saat offline');

  void _showSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: GameTheme.accentAmber,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
