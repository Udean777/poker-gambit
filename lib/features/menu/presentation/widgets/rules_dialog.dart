import 'package:poker_gambit/core/theme/game_theme.dart';
import 'package:flutter/material.dart';

class RulesDialog extends StatelessWidget {
  const RulesDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF0A1F12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: const BorderSide(color: GameTheme.accentAmber, width: 2),
      ),
      title: Column(
        children: [
          const Icon(
            Icons.auto_awesome,
            color: GameTheme.accentAmber,
            size: 40,
          ),
          const SizedBox(height: 12),
          Text(
            "STRATEGI & ATURAN",
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Colors.white,
              fontSize: 20,
              letterSpacing: 2,
            ),
          ),
          Divider(
            color: GameTheme.accentAmber.withValues(alpha: 0.3),
            thickness: 1,
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildSectionTitle(context, "🃏 DASAR PERMAINAN"),
            _buildRuleItem(
              "Susun 5 kartu terbaik Anda di meja untuk melawan AI.",
            ),
            _buildRuleItem(
              "Kartu ke-2 dan ke-4 ditaruh TERTUTUP (Blind Placement).",
            ),

            const SizedBox(height: 16),
            _buildSectionTitle(context, "⚡ ACTION CARDS (SKILL)"),
            _buildRuleItem(
              "J (Spy): Mengintip 1 kartu tangan lawan secara acak.",
            ),
            _buildRuleItem(
              "Q (Witch): Pilih 1 dari 4 kartu dek untuk menyabotase (mengganti acak) kartu tangan lawan.",
            ),
            _buildRuleItem(
              "Joker (Destroyer): Menghapus kartu terakhir lawan di meja.",
            ),

            const SizedBox(height: 16),
            _buildSectionTitle(context, "🎰 MODIFIER SLOTS"),
            _buildRuleItem(
              "Slot 3 (x2): Nilai kartu di posisi ini dikalikan 2!",
            ),
            _buildRuleItem(
              "Slot 4 (Suit Lock): Harus sama simbol dengan Slot 3. Jika beda, nilai kartu jadi 0!",
            ),

            _buildSectionTitle(context, "⏲️ TIMER"),
            _buildRuleItem(
              "Waktu terbatas! Jika timer habis, kartu akan terpasang otomatis.",
            ),
          ],
        ),
      ),
      actionsPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      actions: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: GameTheme.accentAmber,
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 5,
            ),
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              "SAYA MENGERTI",
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Colors.black,
                fontSize: 18,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          color: GameTheme.accentAmber,
          fontSize: 16,
        ),
      ),
    );
  }

  Widget _buildRuleItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "• ",
            style: TextStyle(color: GameTheme.accentAmber, fontSize: 18),
          ),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 13,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
