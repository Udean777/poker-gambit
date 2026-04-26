import 'package:card_games/features/game/domain/logic/i_poker_evaluator.dart';
import 'package:card_games/features/game/domain/models/game_state.dart';

class EvaluateRoundUseCase {
  final IPokerEvaluator _evaluator;

  EvaluateRoundUseCase(this._evaluator);

  GameState execute(GameState currentState) {
    final playerResult = _evaluator.evaluate(currentState.playerTableCards);
    final aiResult = _evaluator.evaluate(currentState.aiTableCards);

    int newPlayerScore = currentState.playerScore;
    int newAiScore = currentState.aiScore;
    final String resultMessage;
    bool? roundPlayerWon;

    if (playerResult.rank.power > aiResult.rank.power) {
      newPlayerScore++;
      roundPlayerWon = true;
      resultMessage = 'MENANG! ${playerResult.rank.label}';
    } else if (aiResult.rank.power > playerResult.rank.power) {
      newAiScore++;
      roundPlayerWon = false;
      resultMessage = 'KALAH! AI punya ${aiResult.rank.label}';
    } else {
      int winner = 0;
      for (
        int i = 0;
        i < playerResult.kickers.length && i < aiResult.kickers.length;
        i++
      ) {
        if (playerResult.kickers[i] > aiResult.kickers[i]) {
          winner = 1;
          break;
        } else if (aiResult.kickers[i] > playerResult.kickers[i]) {
          winner = -1;
          break;
        }
      }

      if (winner == 1) {
        newPlayerScore++;
        roundPlayerWon = true;
        resultMessage = 'MENANG! ${playerResult.rank.label}';
      } else if (winner == -1) {
        newAiScore++;
        roundPlayerWon = false;
        resultMessage = 'KALAH! AI punya ${aiResult.rank.label}';
      } else {
        resultMessage = 'SERI! Keduanya ${playerResult.rank.label}';
      }
    }

    return currentState.copyWith(
      playerScore: newPlayerScore,
      aiScore: newAiScore,
      message: resultMessage,
      lastRoundPlayerWon: roundPlayerWon,
      lastPlayerHandRank: playerResult.rank,
    );
  }
}
