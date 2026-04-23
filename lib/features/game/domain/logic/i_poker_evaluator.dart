import 'package:card_games/features/game/domain/models/card_model.dart';
import 'package:card_games/features/game/domain/models/poker_hand.dart';

abstract class IPokerEvaluator {
  HandResult evaluate(List<CardModel> hand);
}
