import 'package:card_games/domain/models/card_model.dart';

abstract class IPokerAiService {
  /// Decides which cards the AI should discard.
  Future<Map<String, dynamic>> decideDiscard(
    List<CardModel> aiHand, {
    bool canWait = true,
  });

  /// Decides the order in which the AI should play its cards.
  Future<List<int>> decidePlayOrder(
    List<CardModel> aiHand,
    List<CardModel> playerCardsOnTable,
  );
}
