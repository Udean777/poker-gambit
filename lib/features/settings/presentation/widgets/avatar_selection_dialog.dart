import 'package:flutter/material.dart';
import 'package:poker_gambit/features/auth/domain/models/app_user.dart';
import 'package:poker_gambit/features/settings/domain/models/avatar_constants.dart';

class AvatarSelectionDialog extends StatelessWidget {
  final AppUser? user;

  const AvatarSelectionDialog({super.key, this.user});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF1A1F2B),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text(
        'Choose Avatar',
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Select a preset or your Google photo',
              style: TextStyle(color: Colors.white54, fontSize: 13),
            ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              alignment: WrapAlignment.center,
              children: [
                ...presetAvatars.map((url) => _buildAvatarItem(context, url)),
                if (user?.googlePhotoUrl != null)
                  _buildGoogleAvatar(context, user!.googlePhotoUrl!),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('CANCEL', style: TextStyle(color: Colors.white54)),
        ),
      ],
    );
  }

  Widget _buildAvatarItem(BuildContext context, String url) {
    return GestureDetector(
      onTap: () => Navigator.pop(context, url),
      child: CircleAvatar(
        radius: 25,
        backgroundImage: NetworkImage(url),
        backgroundColor: Colors.white12,
      ),
    );
  }

  Widget _buildGoogleAvatar(BuildContext context, String url) {
    return GestureDetector(
      onTap: () => Navigator.pop(context, url),
      child: Stack(
        alignment: Alignment.bottomRight,
        children: [
          CircleAvatar(
            radius: 25,
            backgroundImage: NetworkImage(url),
            backgroundColor: Colors.white12,
          ),
          Container(
            padding: const EdgeInsets.all(2),
            decoration: const BoxDecoration(color: Colors.blue, shape: BoxShape.circle),
            child: const Icon(Icons.g_mobiledata, color: Colors.white, size: 14),
          ),
        ],
      ),
    );
  }
}
