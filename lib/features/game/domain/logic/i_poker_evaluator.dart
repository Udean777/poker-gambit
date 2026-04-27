import 'package:poker_gambit/features/game/domain/models/card_model.dart';
import 'package:poker_gambit/features/game/domain/models/poker_hand.dart';

abstract class IPokerEvaluator {
  HandResult evaluate(List<CardModel> hand);
}
