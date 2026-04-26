import 'package:flutter_test/flutter_test.dart';
import 'package:card_games/features/game/domain/services/deck_service.dart';
import 'package:card_games/features/game/domain/models/card_model.dart';
import 'package:card_games/core/constants/game_constants.dart';

void main() {
  late DeckService deckService;

  setUp(() {
    deckService = DeckService();
  });

  group('DeckService', () {
    test('createShuffledDeck should return 54 cards (52 + 2 jokers)', () {
      final deck = deckService.createShuffledDeck();
      expect(deck.length, 54);

      final jokers = deck.where((c) => c.suit == CardSuit.joker).toList();
      expect(jokers.length, 2);

      final hearts = deck.where((c) => c.suit == CardSuit.heart).toList();
      expect(hearts.length, 13);
    });

    test('dealInitialHands should distribute cards correctly', () {
      final deck = deckService.createShuffledDeck();
      final result = deckService.dealInitialHands(deck);

      expect(result.playerHand.length, GameConstants.handSize);
      expect(result.aiHand.length, GameConstants.handSize);
      expect(result.remainingDeck.length, 54 - (2 * GameConstants.handSize));

      // Player cards should be face up
      for (var card in result.playerHand) {
        expect(card.isFaceUp, isTrue);
      }

      // AI cards should be face down
      for (var card in result.aiHand) {
        expect(card.isFaceUp, isFalse);
      }
    });

    test('drawCards should remove cards from deck and return them', () {
      final deck = deckService.createShuffledDeck();
      final initialCount = deck.length;
      const drawCount = 3;

      final result = deckService.drawCards(deck, drawCount, faceUp: true);

      expect(result.drawnCards.length, drawCount);
      expect(result.remainingDeck.length, initialCount - drawCount);

      for (var card in result.drawnCards) {
        expect(card.isFaceUp, isTrue);
      }
    });

    test('drawCards should handle empty deck', () {
      final List<CardModel> emptyDeck = [];
      final result = deckService.drawCards(emptyDeck, 5);

      expect(result.drawnCards, isEmpty);
      expect(result.remainingDeck, isEmpty);
    });
  });
}
