import 'package:poker_gambit/core/theme/game_theme.dart';
import 'package:poker_gambit/core/widgets/app_scaffold.dart';
import 'package:poker_gambit/features/menu/domain/models/card_combo.dart';
import 'package:poker_gambit/features/menu/presentation/widgets/combo_card_widget.dart';
import 'package:flutter/material.dart';

class CardGalleryScreen extends StatelessWidget {
  const CardGalleryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      decoration: GameTheme.tableGradient,
      appBar: AppBar(
        title: Text(
          'STRATEGY GUIDE',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: Colors.white,
            letterSpacing: 2,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        children: [
          const Text(
            "Pelajari kombinasi kartu dan cara meng-counter lawan untuk memenangkan Poker Gambit!",
            style: TextStyle(color: Colors.white70, fontSize: 14),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 25),
          ...cardCombosData.map((combo) => ComboCardWidget(combo: combo)),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}
