import 'package:poker_gambit/features/game/domain/models/card_model.dart';

class RoundResultInfo {
  final bool? isPlayerWinner;
  final String playerHandName;
  final List<CardModel> playerTableCards;
  final String aiHandName;
  final List<CardModel> aiTableCards;
  final String resultMessage;

  const RoundResultInfo({
    required this.isPlayerWinner,
    required this.playerHandName,
    required this.playerTableCards,
    required this.aiHandName,
    required this.aiTableCards,
    required this.resultMessage,
  });
}
