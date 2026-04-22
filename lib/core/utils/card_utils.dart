import 'package:card_games/domain/models/card_model.dart';

class CardUtils {
  CardUtils._();

  /// Removes cards at [indices] from [cards], handling reverse-order removal.
  static List<CardModel> removeAtIndices(
    List<CardModel> cards,
    List<int> indices,
  ) {
    final result = List<CardModel>.from(cards);
    final sorted = List<int>.from(indices)..sort((a, b) => b.compareTo(a));
    for (final index in sorted) {
      if (index >= 0 && index < result.length) {
        result.removeAt(index);
      }
    }
    return result;
  }
}
