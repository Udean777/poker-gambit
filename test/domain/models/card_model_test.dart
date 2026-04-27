import 'package:flutter_test/flutter_test.dart';
import 'package:poker_gambit/features/game/domain/models/card_model.dart';

void main() {
  group('CardModel', () {
    test('should create a CardModel with correct properties', () {
      const card = CardModel(value: 10, suit: CardSuit.heart, isFaceUp: true);

      expect(card.value, 10);
      expect(card.suit, CardSuit.heart);
      expect(card.isFaceUp, true);
    });

    test('assetPath should return correct path for normal cards', () {
      const card = CardModel(value: 1, suit: CardSuit.spade);
      expect(card.assetPath, 'assets/images/cards/spade_1.svg');
    });

    test('assetPath should return correct path for Joker', () {
      const redJoker = CardModel(value: 1, suit: CardSuit.joker);
      const blackJoker = CardModel(value: 2, suit: CardSuit.joker);

      expect(redJoker.assetPath, 'assets/images/cards/joker_red.svg');
      expect(blackJoker.assetPath, 'assets/images/cards/joker_black.svg');
    });

    test('copyWith should update properties correctly', () {
      const card = CardModel(value: 5, suit: CardSuit.club);
      final updated = card.copyWith(isFaceUp: true);

      expect(updated.value, 5);
      expect(updated.suit, CardSuit.club);
      expect(updated.isFaceUp, true);
    });

    test('suitIcon should return correct emoji', () {
      expect(const CardModel(value: 1, suit: CardSuit.heart).suitIcon, "❤️");
      expect(const CardModel(value: 1, suit: CardSuit.diamond).suitIcon, "💎");
      expect(const CardModel(value: 1, suit: CardSuit.club).suitIcon, "♣️");
      expect(const CardModel(value: 1, suit: CardSuit.spade).suitIcon, "♠️");
      expect(const CardModel(value: 1, suit: CardSuit.joker).suitIcon, "🃏");
    });

    test('valueLabel should return correct string', () {
      expect(const CardModel(value: 1, suit: CardSuit.heart).valueLabel, "A");
      expect(const CardModel(value: 11, suit: CardSuit.heart).valueLabel, "J");
      expect(const CardModel(value: 12, suit: CardSuit.heart).valueLabel, "Q");
      expect(const CardModel(value: 13, suit: CardSuit.heart).valueLabel, "K");
      expect(const CardModel(value: 7, suit: CardSuit.heart).valueLabel, "7");
      expect(const CardModel(value: 1, suit: CardSuit.joker).valueLabel, "JK");
    });
  });
}
