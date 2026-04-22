import 'dart:math';

import 'package:card_games/core/constants/game_constants.dart';
import 'package:card_games/domain/models/card_model.dart';

import 'package:card_games/domain/services/i_deck_service.dart';

/// Pure service responsible for deck creation and card dealing.
///
/// Follows Single Responsibility Principle — only handles
/// deck-related operations without any game state knowledge.
class DeckService implements IDeckService {
  /// Creates a standard 52-card deck plus 2 Jokers, shuffled.
  @override
  List<CardModel> createShuffledDeck() {
    final deck = <CardModel>[];

    for (final suit in CardSuit.values) {
      if (suit == CardSuit.joker) continue;
      for (var i = 1; i <= GameConstants.maxCardValue; i++) {
        deck.add(CardModel(value: i, suit: suit));
      }
    }

    // Add Red & Black Jokers
    deck.add(
      const CardModel(value: GameConstants.jokerRedValue, suit: CardSuit.joker),
    );
    deck.add(
      const CardModel(
        value: GameConstants.jokerBlackValue,
        suit: CardSuit.joker,
      ),
    );

    deck.shuffle(Random());
    return deck;
  }

  /// Deals [GameConstants.handSize] cards to each player from [deck].
  ///
  /// Player cards are dealt face-up, AI cards face-down.
  @override
  DealResult dealInitialHands(List<CardModel> deck) {
    final mutableDeck = List<CardModel>.from(deck);
    final handSize = GameConstants.handSize;

    final playerHand = mutableDeck
        .sublist(0, handSize)
        .map((c) => c.copyWith(isFaceUp: true))
        .toList();
    mutableDeck.removeRange(0, handSize);

    final aiHand = mutableDeck.sublist(0, handSize).toList();
    mutableDeck.removeRange(0, handSize);

    return DealResult(
      playerHand: playerHand,
      aiHand: aiHand,
      remainingDeck: mutableDeck,
    );
  }

  /// Draws [count] cards from the top of [deck].
  @override
  DrawResult drawCards(List<CardModel> deck, int count, {bool faceUp = false}) {
    final mutableDeck = List<CardModel>.from(deck);
    final drawn = <CardModel>[];

    for (var i = 0; i < count && mutableDeck.isNotEmpty; i++) {
      var card = mutableDeck.removeAt(0);
      if (faceUp) card = card.copyWith(isFaceUp: true);
      drawn.add(card);
    }

    return DrawResult(drawnCards: drawn, remainingDeck: mutableDeck);
  }
}
