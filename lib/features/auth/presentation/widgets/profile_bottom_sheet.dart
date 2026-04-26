import 'package:card_games/core/theme/game_theme.dart';
import 'package:card_games/features/auth/domain/models/app_user.dart';
import 'package:card_games/features/auth/presentation/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProfileBottomSheet extends ConsumerStatefulWidget {
  const ProfileBottomSheet({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => const ProfileBottomSheet(),
    );
  }

  @override
  ConsumerState<ProfileBottomSheet> createState() => _ProfileBottomSheetState();
}

class _ProfileBottomSheetState extends ConsumerState<ProfileBottomSheet> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    ref.listenManual(authStateProvider, (previous, next) {
      final prevUser = previous?.valueOrNull;
      final nextUser = next.valueOrNull;
      if (prevUser?.isGuest == true && nextUser?.isGuest == false) {
        debugPrint('[ProfileSheet] user upgraded, closing sheet');
        if (mounted) Navigator.of(context).pop();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    final currentUser = ref.watch(authStateProvider).valueOrNull;

    return Container(
      decoration: BoxDecoration(
        color: GameTheme.secondaryGreen,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border.all(color: Colors.white10),
      ),
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),
          _buildUserInfo(currentUser),
          const SizedBox(height: 32),
          if (authState.isLoading)
            const SizedBox(
              width: double.infinity,
              height: 56,
              child: Center(
                child: CircularProgressIndicator(color: GameTheme.accentAmber),
              ),
            )
          else ...[
            if (currentUser?.isGuest == true)
              _ActionButton(
                icon: Icons.login,
                label: 'Login dengan Google',
                color: GameTheme.accentAmber,
                onTap: () async {
                  await ref
                      .read(authNotifierProvider.notifier)
                      .upgradeToGoogle();
                },
              )
            else
              _ActionButton(
                icon: Icons.logout,
                label: 'Logout',
                color: Colors.redAccent,
                onTap: () async {
                  await ref.read(authNotifierProvider.notifier).signOut();
                  if (context.mounted) Navigator.pop(context);
                },
              ),
          ],
          if (authState.hasError) ...[
            const SizedBox(height: 12),
            Text(
              authState.error.toString(),
              style: const TextStyle(color: Colors.redAccent, fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildUserInfo(AppUser? user) {
    if (user == null) return const SizedBox.shrink();

    return Column(
      children: [
        CircleAvatar(
          radius: 36,
          backgroundColor: Colors.white12,
          backgroundImage: user.photoUrl != null
              ? NetworkImage(user.photoUrl!)
              : null,
          child: user.photoUrl == null
              ? Icon(
                  user.isGuest ? Icons.person_outline : Icons.person,
                  size: 36,
                  color: Colors.white54,
                )
              : null,
        ),
        const SizedBox(height: 12),
        Text(
          user.displayName,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        if (user.email != null) ...[
          const SizedBox(height: 4),
          Text(
            user.email!,
            style: const TextStyle(color: Colors.white54, fontSize: 13),
          ),
        ],
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: user.isGuest
                ? Colors.white10
                : Colors.green.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: user.isGuest ? Colors.white24 : Colors.green,
              width: 1,
            ),
          ),
          child: Text(
            user.isGuest ? 'Guest' : 'Member',
            style: TextStyle(
              color: user.isGuest ? Colors.white54 : Colors.greenAccent,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 20),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          backgroundColor: color.withValues(alpha: 0.15),
          foregroundColor: color,
          padding: const EdgeInsets.symmetric(vertical: 16),
          side: BorderSide(color: color.withValues(alpha: 0.5)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
      ),
    );
  }
}
