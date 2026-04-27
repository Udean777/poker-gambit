import 'package:poker_gambit/features/game/domain/models/card_model.dart';

abstract class IPokerAiService {
  /// Decides which cards the AI should discard.
  Future<Map<String, dynamic>> decideDiscard(
    List<CardModel> aiHand, {
    bool canWait = true,
    int timeLeft = 0,
  });

  /// Decides the order in which the AI should play its cards.
  Future<List<int>> decidePlayOrder(
    List<CardModel> aiHand,
    List<CardModel> playerCardsOnTable, {
    int timeLeft = 0,
  });

  /// Selects the "worst" card from a list to sabotage the opponent.
  Future<CardModel> selectWorstCard(List<CardModel> options);
}
