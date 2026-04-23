import 'package:card_games/features/game/domain/models/card_model.dart';

/// Result of dealing initial hands to both players.
class DealResult {
  final List<CardModel> playerHand;
  final List<CardModel> aiHand;
  final List<CardModel> remainingDeck;

  const DealResult({
    required this.playerHand,
    required this.aiHand,
    required this.remainingDeck,
  });
}

/// Result of drawing cards from the deck.
class DrawResult {
  final List<CardModel> drawnCards;
  final List<CardModel> remainingDeck;

  const DrawResult({required this.drawnCards, required this.remainingDeck});
}

abstract class IDeckService {
  /// Creates a standard 52-card deck plus 2 Jokers, shuffled.
  List<CardModel> createShuffledDeck();

  /// Deals cards to each player from [deck].
  DealResult dealInitialHands(List<CardModel> deck);

  /// Draws [count] cards from the top of [deck].
  DrawResult drawCards(List<CardModel> deck, int count, {bool faceUp = false});
}
