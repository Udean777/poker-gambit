import 'package:poker_gambit/features/auth/domain/models/app_user.dart';
import 'package:flutter/material.dart';

class UserAvatarWidget extends StatelessWidget {
  final AppUser user;
  final VoidCallback onTap;

  const UserAvatarWidget({super.key, required this.user, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildAvatar(),
          const SizedBox(width: 8),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 100),
            child: Text(
              user.displayName,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar() {
    if (user.isGuest || user.photoUrl == null) {
      return CircleAvatar(
        radius: 16,
        backgroundColor: Colors.white12,
        child: Icon(
          user.isGuest ? Icons.person_outline : Icons.person,
          size: 18,
          color: Colors.white54,
        ),
      );
    }

    return CircleAvatar(
      radius: 16,
      backgroundImage: NetworkImage(user.photoUrl!),
      backgroundColor: Colors.white12,
    );
  }
}
