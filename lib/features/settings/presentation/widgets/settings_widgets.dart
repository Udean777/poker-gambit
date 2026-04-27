import 'package:flutter/material.dart';
import 'package:poker_gambit/core/theme/game_theme.dart';
import 'package:poker_gambit/features/auth/domain/models/app_user.dart';

class ProfileCard extends StatelessWidget {
  final AppUser user;
  final bool isEditing;
  final bool isLoading;
  final TextEditingController nameController;
  final VoidCallback onEditToggle;
  final VoidCallback onAvatarTap;

  const ProfileCard({
    super.key,
    required this.user,
    required this.isEditing,
    required this.isLoading,
    required this.nameController,
    required this.onEditToggle,
    required this.onAvatarTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        children: [
          Row(
            children: [
              _buildAvatarStack(),
              const SizedBox(width: 16),
              _buildUserInfo(),
              _buildActionIcon(),
            ],
          ),
          if (user.isGuest) ...[
            const SizedBox(height: 16),
            const Divider(color: Colors.white10),
            const SizedBox(height: 8),
            const Text(
              'Sign in to sync your progress across devices and join the leaderboard.',
              style: TextStyle(color: Colors.white38, fontSize: 11),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAvatarStack() {
    return Stack(
      children: [
        CircleAvatar(
          radius: 35,
          backgroundColor: Colors.white12,
          backgroundImage: user.photoUrl != null
              ? NetworkImage(user.photoUrl!)
              : null,
          child: user.photoUrl == null
              ? const Icon(Icons.person, color: Colors.white54, size: 35)
              : null,
        ),
        if (isEditing)
          Positioned.fill(
            child: GestureDetector(
              onTap: onAvatarTap,
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.black45,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.camera_alt,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildUserInfo() {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isEditing)
            TextField(
              controller: nameController,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
              decoration: const InputDecoration(
                hintText: 'Enter your name',
                hintStyle: TextStyle(color: Colors.white38),
                isDense: true,
                contentPadding: EdgeInsets.symmetric(vertical: 8),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: GameTheme.accentAmber),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                    color: GameTheme.accentAmber,
                    width: 2,
                  ),
                ),
              ),
            )
          else
            Text(
              user.displayName,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          const SizedBox(height: 4),
          Text(
            user.isGuest ? 'Guest Account' : (user.email ?? 'Member Account'),
            style: const TextStyle(color: Colors.white54, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildActionIcon() {
    if (isLoading) {
      return const SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: GameTheme.accentAmber,
        ),
      );
    }
    return IconButton(
      icon: Icon(
        isEditing ? Icons.check : Icons.edit,
        color: GameTheme.accentAmber,
      ),
      onPressed: onEditToggle,
    );
  }
}

class SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool isLocked;
  final Widget? trailing;

  const SettingsTile({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.isLocked = false,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: isLocked ? Colors.white38 : Colors.white70),
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isLocked ? Colors.white70 : Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(color: Colors.white38, fontSize: 12),
        ),
        trailing:
            trailing ??
            (isLocked
                ? const Icon(
                    Icons.lock_outline,
                    color: Colors.white24,
                    size: 18,
                  )
                : const Icon(
                    Icons.chevron_right,
                    color: Colors.white24,
                    size: 18,
                  )),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        tileColor: Colors.white.withValues(alpha: 0.02),
      ),
    );
  }
}
