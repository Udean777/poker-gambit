import 'package:card_games/core/theme/game_theme.dart';
import 'package:card_games/core/widgets/app_scaffold.dart';
import 'package:card_games/features/game/domain/models/card_model.dart';
import 'package:card_games/features/game/presentation/widgets/playing_card.dart';
import 'package:flutter/material.dart';

class CardGalleryScreen extends StatelessWidget {
  const CardGalleryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      decoration: GameTheme.tableGradient,
      appBar: AppBar(
        title: Text(
          'CARD COLLECTION',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: Colors.white,
            letterSpacing: 2,
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
        padding: const EdgeInsets.all(16),
        children: [
          _buildCategory(context, 'CLUBS', CardSuit.club),
          _buildCategory(context, 'HEARTS', CardSuit.heart),
          _buildCategory(context, 'DIAMONDS', CardSuit.diamond),
          _buildCategory(context, 'SPADES', CardSuit.spade),
          _buildSpecialCategory(context),
        ],
      ),
    );
  }

  Widget _buildCategory(BuildContext context, String title, CardSuit suit) {
    final cards = List.generate(
      13,
      (index) => CardModel(value: index + 1, suit: suit, isFaceUp: true),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Text(
            title,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: GameTheme.accentAmber,
              letterSpacing: 2,
            ),
          ),
        ),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            childAspectRatio: 0.7,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemCount: cards.length,
          itemBuilder: (context, index) {
            return PlayingCard(card: cards[index]);
          },
        ),
      ],
    );
  }

  Widget _buildSpecialCategory(BuildContext context) {
    final specials = [
      const CardModel(value: 14, suit: CardSuit.joker, isFaceUp: true),
      const CardModel(value: 15, suit: CardSuit.joker, isFaceUp: true),
      const CardModel(
        value: 1,
        suit: CardSuit.club,
        isFaceUp: false,
      ), // Representative Card Back
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Text(
            'SPECIAL',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: GameTheme.accentAmber,
              letterSpacing: 2,
            ),
          ),
        ),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            childAspectRatio: 0.7,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemCount: specials.length,
          itemBuilder: (context, index) {
            return PlayingCard(card: specials[index]);
          },
        ),
        const SizedBox(height: 32),
      ],
    );
  }
}
