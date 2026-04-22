import 'package:card_games/domain/models/card_model.dart';
import 'package:card_games/domain/models/poker_hand.dart';

abstract class IPokerEvaluator {
  HandResult evaluate(List<CardModel> hand);
}
