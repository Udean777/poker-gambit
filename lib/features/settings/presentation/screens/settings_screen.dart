import 'package:poker_gambit/core/localization/locale_provider.dart';
import 'package:poker_gambit/core/theme/game_theme.dart';
import 'package:poker_gambit/core/widgets/app_scaffold.dart';
import 'package:poker_gambit/features/auth/presentation/providers/auth_provider.dart';
import 'package:poker_gambit/features/settings/presentation/widgets/avatar_selection_dialog.dart';
import 'package:poker_gambit/features/settings/presentation/widgets/settings_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:poker_gambit/l10n/app_localizations.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final _nameController = TextEditingController();
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    final user = ref.read(userProfileProvider);
    if (user != null) _nameController.text = user.displayName;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _showComingSoon() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text(
          'Coming soon!',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: GameTheme.accentAmber,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Future<void> _updateAvatar() async {
    final user = ref.read(userProfileProvider);
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AvatarSelectionDialog(user: user),
    );

    if (result != null && result.isNotEmpty) {
      await ref.read(authNotifierProvider.notifier).updatePhotoUrl(result);
    }
  }

  Future<void> _updateProfile() async {
    final newName = _nameController.text.trim();
    if (newName.isEmpty) return;

    await ref.read(authNotifierProvider.notifier).updateDisplayName(newName);

    if (mounted) {
      setState(() => _isEditing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile updated successfully!'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProfileProvider);
    final authState = ref.watch(authNotifierProvider);
    final l10n = AppLocalizations.of(context)!;

    ref.listen(userProfileProvider, (prev, next) {
      if (next != null &&
          (prev == null || prev.displayName != next.displayName)) {
        if (!_isEditing) _nameController.text = next.displayName;
      }
    });

    return AppScaffold(
      decoration: GameTheme.tableGradient,
      appBar: AppBar(
        title: Text(
          l10n.settings,
          style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 2),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle(l10n.profileSection),
            const SizedBox(height: 16),
            if (user != null)
              ProfileCard(
                user: user,
                isEditing: _isEditing,
                isLoading: authState.isLoading,
                nameController: _nameController,
                onEditToggle: () {
                  if (_isEditing) {
                    _updateProfile();
                  } else {
                    setState(() => _isEditing = true);
                  }
                },
                onAvatarTap: _updateAvatar,
              ),
            const SizedBox(height: 32),
            _buildSectionTitle(l10n.gameSettingsSection),
            const SizedBox(height: 16),
            SettingsTile(
              icon: Icons.music_note,
              title: 'Music',
              subtitle: 'Adjust background music volume',
              onTap: _showComingSoon,
              isLocked: true,
            ),
            SettingsTile(
              icon: Icons.volume_up,
              title: 'Sound Effects',
              subtitle: 'Adjust SFX volume',
              onTap: _showComingSoon,
              isLocked: true,
            ),
            SettingsTile(
              icon: Icons.palette,
              title: 'Theme',
              subtitle: 'Change table and card themes',
              onTap: _showComingSoon,
              isLocked: true,
            ),
            _buildLanguageTile(context, ref),
            const SizedBox(height: 32),
            _buildSectionTitle(l10n.aboutSection),
            const SizedBox(height: 16),
            _buildAboutTile(Icons.info_outline, 'Version', '1.0.0'),
            _buildAboutTile(
              Icons.policy,
              'Privacy Policy',
              'Read our privacy policy',
            ),
            const SizedBox(height: 48),
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        color: GameTheme.accentAmber.withValues(alpha: 0.7),
        fontSize: 14,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.5,
      ),
    );
  }

  Widget _buildLanguageTile(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final currentLocale = ref.watch(localeStateProvider);
    return SettingsTile(
      icon: Icons.language,
      title: l10n.language,
      subtitle: currentLocale.languageCode == 'en'
          ? l10n.english
          : l10n.indonesian,
      onTap: () => _showLanguageDialog(context, ref),
    );
  }

  void _showLanguageDialog(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final currentLocale = ref.read(localeStateProvider);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1F2B),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          l10n.language,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildLanguageOption(
              context,
              ref,
              l10n.english,
              'en',
              currentLocale.languageCode == 'en',
            ),
            _buildLanguageOption(
              context,
              ref,
              l10n.indonesian,
              'id',
              currentLocale.languageCode == 'id',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageOption(
    BuildContext context,
    WidgetRef ref,
    String label,
    String code,
    bool isSelected,
  ) {
    return ListTile(
      title: Text(
        label,
        style: TextStyle(
          color: isSelected ? GameTheme.accentAmber : Colors.white,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      trailing: isSelected
          ? const Icon(Icons.check, color: GameTheme.accentAmber)
          : null,
      onTap: () {
        ref.read(localeStateProvider.notifier).setLocale(Locale(code));
        Navigator.pop(context);
      },
    );
  }

  Widget _buildAboutTile(IconData icon, String title, String trailingText) {
    return SettingsTile(
      icon: icon,
      title: title,
      subtitle: '',
      onTap: _showComingSoon,
      trailing: Text(
        trailingText,
        style: const TextStyle(
          color: Colors.white38,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Center(
      child: Opacity(
        opacity: 0.5,
        child: Column(
          children: [
            Image.asset(
              'assets/images/poker-gambit.png',
              height: 40,
              errorBuilder: (_, _, _) =>
                  const Icon(Icons.casino, size: 40, color: Colors.white24),
            ),
            const SizedBox(height: 8),
            Text(
              '© ${DateTime.now().year} Poker Gambit Team',
              style: const TextStyle(color: Colors.white54, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
