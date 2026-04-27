import 'package:poker_gambit/core/providers/connectivity_provider.dart';
import 'package:poker_gambit/core/theme/game_theme.dart';
import 'package:poker_gambit/core/widgets/app_scaffold.dart';
import 'package:poker_gambit/features/auth/presentation/providers/auth_provider.dart';
import 'package:poker_gambit/features/auth/presentation/widgets/profile_bottom_sheet.dart';
import 'package:poker_gambit/features/auth/presentation/widgets/user_avatar_widget.dart';
import 'package:poker_gambit/features/menu/presentation/widgets/login_banner.dart';
import 'package:poker_gambit/features/menu/presentation/widgets/menu_logo.dart';
import 'package:poker_gambit/features/menu/presentation/widgets/sync_indicator.dart';
import 'package:poker_gambit/features/menu/presentation/widgets/menu_buttons_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:poker_gambit/core/services/image_precache_service.dart';
import 'package:poker_gambit/features/auth/domain/models/app_user.dart';

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

    WidgetsBinding.instance.addPostFrameCallback(
      (_) => ImagePrecacheService.precacheAllCards(context),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authAsync = ref.watch(authStateProvider);
    final user = ref.watch(userProfileProvider);
    final isOnline = ref.watch(connectivityProvider).valueOrNull ?? false;

    return AppScaffold(
      decoration: GameTheme.tableGradient,
      body: Stack(
        children: [
          FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 56, 24, 32),
                  child: Column(
                    children: [
                      const MenuLogo(),
                      const SizedBox(height: 24),
                      if (user?.isGuest ?? true) ...[
                        LoginBanner(
                          onTap: () => ProfileBottomSheet.show(context),
                          isLoading: authAsync.isLoading,
                        ),
                        const SizedBox(height: 16),
                      ],
                      MenuButtonsList(
                        isOnline: isOnline,
                        onShowSnackbar: (msg) => _showSnackbar(context, msg),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          _buildTopBar(user, isOnline),
        ],
      ),
    );
  }

  Widget _buildTopBar(AppUser? user, bool isOnline) {
    return Positioned(
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
    );
  }

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
