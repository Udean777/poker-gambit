import 'package:flutter_test/flutter_test.dart';
import 'package:card_games/features/game/domain/models/card_model.dart';
import 'package:card_games/features/game/domain/models/poker_hand.dart';
import 'package:card_games/features/game/domain/logic/poker_evaluator.dart';

void main() {
  late PokerEvaluator evaluator;

  setUp(() {
    evaluator = PokerEvaluator();
  });

  group(
    'PokerEvaluator - Standard Hands (Using Joker in Slot 3 to avoid boost)',
    () {
      test('Royal Flush', () {
        final hand = [
          const CardModel(value: 1, suit: CardSuit.heart), // Ace
          const CardModel(value: 13, suit: CardSuit.heart), // King
          const CardModel(
            value: 1,
            suit: CardSuit.joker,
          ), // Joker in Slot 3 (index 2) -> will become Queen
          const CardModel(value: 11, suit: CardSuit.heart), // Jack
          const CardModel(value: 10, suit: CardSuit.heart), // 10
        ];
        final result = evaluator.evaluate(hand);
        expect(result.rank, PokerHandRank.royalFlush);
      });

      test('Straight Flush', () {
        final hand = [
          const CardModel(value: 9, suit: CardSuit.club),
          const CardModel(value: 8, suit: CardSuit.club),
          const CardModel(
            value: 1,
            suit: CardSuit.joker,
          ), // Joker -> will become 7
          const CardModel(value: 6, suit: CardSuit.club),
          const CardModel(value: 5, suit: CardSuit.club),
        ];
        final result = evaluator.evaluate(hand);
        expect(result.rank, PokerHandRank.straightFlush);
      });

      test('Four of a Kind', () {
        final hand = [
          const CardModel(value: 7, suit: CardSuit.heart),
          const CardModel(value: 7, suit: CardSuit.diamond),
          const CardModel(
            value: 1,
            suit: CardSuit.joker,
          ), // Joker -> will become 7
          const CardModel(value: 7, suit: CardSuit.spade),
          const CardModel(value: 2, suit: CardSuit.heart),
        ];
        final result = evaluator.evaluate(hand);
        expect(result.rank, PokerHandRank.fourOfAKind);
        expect(result.kickers[0], 7);
      });

      test('Full House', () {
        final hand = [
          const CardModel(value: 10, suit: CardSuit.heart),
          const CardModel(value: 10, suit: CardSuit.diamond),
          const CardModel(
            value: 1,
            suit: CardSuit.joker,
          ), // Joker -> will become 10
          const CardModel(value: 3, suit: CardSuit.spade),
          const CardModel(value: 3, suit: CardSuit.heart),
        ];
        final result = evaluator.evaluate(hand);
        expect(result.rank, PokerHandRank.fullHouse);
        expect(result.kickers[0], 10);
        expect(result.kickers[1], 3);
      });

      test('Flush', () {
        final hand = [
          const CardModel(value: 2, suit: CardSuit.spade),
          const CardModel(value: 5, suit: CardSuit.spade),
          const CardModel(
            value: 1,
            suit: CardSuit.joker,
          ), // Joker -> will become high spade
          const CardModel(value: 11, suit: CardSuit.spade),
          const CardModel(value: 13, suit: CardSuit.spade),
        ];
        final result = evaluator.evaluate(hand);
        expect(result.rank, PokerHandRank.flush);
      });

      test('Straight (Wheel: A-2-3-4-5)', () {
        final hand = [
          const CardModel(value: 1, suit: CardSuit.heart), // Ace
          const CardModel(value: 2, suit: CardSuit.diamond),
          const CardModel(
            value: 1,
            suit: CardSuit.joker,
          ), // Joker -> will become 3
          const CardModel(value: 4, suit: CardSuit.spade),
          const CardModel(value: 5, suit: CardSuit.heart),
        ];
        final result = evaluator.evaluate(hand);
        expect(result.rank, PokerHandRank.straight);
        expect(result.kickers[0], 5);
      });

      test('Three of a Kind', () {
        final hand = [
          const CardModel(value: 9, suit: CardSuit.heart),
          const CardModel(value: 9, suit: CardSuit.diamond),
          const CardModel(
            value: 1,
            suit: CardSuit.joker,
          ), // Joker -> will become 9
          const CardModel(value: 4, suit: CardSuit.spade),
          const CardModel(value: 2, suit: CardSuit.heart),
        ];
        final result = evaluator.evaluate(hand);
        expect(result.rank, PokerHandRank.threeOfAKind);
        expect(result.kickers[0], 9);
      });

      test('Two Pair', () {
        final hand = [
          const CardModel(value: 11, suit: CardSuit.heart),
          const CardModel(value: 11, suit: CardSuit.diamond),
          const CardModel(
            value: 2,
            suit: CardSuit.club,
          ), // Slot 3 -> becomes 22
          const CardModel(value: 4, suit: CardSuit.spade),
          const CardModel(value: 4, suit: CardSuit.heart),
        ];
        final result = evaluator.evaluate(hand);
        expect(result.rank, PokerHandRank.twoPair);
        expect(result.kickers[0], 11);
        expect(result.kickers[1], 4);
        expect(result.kickers[2], 22);
      });

      test('One Pair', () {
        final hand = [
          const CardModel(value: 1, suit: CardSuit.heart), // Ace (14)
          const CardModel(value: 1, suit: CardSuit.diamond), // Ace (14)
          const CardModel(
            value: 7,
            suit: CardSuit.club,
          ), // Slot 3 -> becomes 27
          const CardModel(value: 8, suit: CardSuit.spade),
          const CardModel(value: 2, suit: CardSuit.heart),
        ];
        final result = evaluator.evaluate(hand);
        expect(result.rank, PokerHandRank.onePair);
        expect(result.kickers[0], 14);
        expect(result.kickers[1], 27); // 27 is the high kicker now
      });

      test('High Card', () {
        final hand = [
          const CardModel(value: 13, suit: CardSuit.heart), // King
          const CardModel(value: 11, suit: CardSuit.diamond), // Jack
          const CardModel(
            value: 3,
            suit: CardSuit.club,
          ), // Slot 3 -> becomes 23
          const CardModel(value: 8, suit: CardSuit.spade),
          const CardModel(value: 2, suit: CardSuit.heart),
        ];
        final result = evaluator.evaluate(hand);
        expect(result.rank, PokerHandRank.highCard);
        expect(result.kickers[0], 23); // Boosted card is highest
      });
    },
  );

  group('PokerEvaluator - Special Mechanics', () {
    test('Five of a Kind (with Joker)', () {
      final hand = [
        const CardModel(value: 10, suit: CardSuit.heart),
        const CardModel(value: 10, suit: CardSuit.diamond),
        const CardModel(
          value: 1,
          suit: CardSuit.joker,
        ), // Joker in slot 3 -> NO BOOST
        const CardModel(value: 10, suit: CardSuit.club),
        const CardModel(value: 10, suit: CardSuit.spade),
      ];
      final result = evaluator.evaluate(hand);
      expect(result.rank, PokerHandRank.fiveOfAKind);
      expect(result.kickers[0], 10);
    });

    test('Slot 3 "x2 Power" modifier should boost card value by 20', () {
      // Index 2 is the 3rd card
      final hand = [
        const CardModel(value: 2, suit: CardSuit.heart),
        const CardModel(value: 3, suit: CardSuit.heart),
        const CardModel(
          value: 10,
          suit: CardSuit.spade,
        ), // Slot 3 -> value will be 20 + 10 = 30
        const CardModel(value: 4, suit: CardSuit.heart),
        const CardModel(value: 5, suit: CardSuit.heart),
      ];
      final result = evaluator.evaluate(hand);
      // The 10 becomes 30 (highest card)
      expect(result.rank, PokerHandRank.highCard);
      expect(result.kickers[0], 30);
    });

    test('Invalidated cards (value 0) should be ignored', () {
      final hand = [
        const CardModel(value: 10, suit: CardSuit.heart),
        const CardModel(value: 10, suit: CardSuit.diamond),
        const CardModel(value: 0, suit: CardSuit.club), // Invalidated
        const CardModel(value: 4, suit: CardSuit.spade),
        const CardModel(value: 2, suit: CardSuit.heart),
      ];
      final result = evaluator.evaluate(hand);
      // Without the 0 card, we have 10, 10, 4, 2 -> One Pair
      expect(result.rank, PokerHandRank.onePair);
      expect(result.kickers.length, lessThan(5));
    });
  });
}
