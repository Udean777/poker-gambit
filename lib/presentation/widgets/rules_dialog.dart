import 'package:card_games/core/theme/game_theme.dart';
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
          const Text(
            "STRATEGI & ATURAN",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
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
            _buildSectionTitle("🃏 DASAR PERMAINAN"),
            _buildRuleItem(
              "Susun 5 kartu terbaik Anda di meja untuk melawan AI.",
            ),
            _buildRuleItem(
              "Kartu ke-2 dan ke-4 ditaruh TERTUTUP (Blind Placement).",
            ),

            const SizedBox(height: 16),
            _buildSectionTitle("⚡ ACTION CARDS (SKILL)"),
            _buildRuleItem(
              "J (Spy): Mengintip 1 kartu tangan lawan secara acak.",
            ),
            _buildRuleItem(
              "Q (Witch): Menukar 1 kartu di tangan Anda dari dek.",
            ),
            _buildRuleItem(
              "Joker (Destroyer): Menghapus kartu terakhir lawan di meja.",
            ),

            const SizedBox(height: 16),
            _buildSectionTitle("🎰 MODIFIER SLOTS"),
            _buildRuleItem(
              "Slot 3 (x2): Nilai kartu di posisi ini dikalikan 2!",
            ),
            _buildRuleItem(
              "Slot 4 (Suit Lock): Harus sama simbol dengan Slot 3. Jika beda, nilai kartu jadi 0!",
            ),

            const SizedBox(height: 16),
            _buildSectionTitle("🛡️ COUNTER & TIMER"),
            _buildRuleItem(
              "Gunakan tombol COUNTER saat AI memakai skill untuk menggagalkannya!",
            ),
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
            child: const Text(
              "SAYA MENGERTI",
              style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          color: GameTheme.accentAmber,
          fontWeight: FontWeight.bold,
          fontSize: 14,
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
