import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:card_games/domain/logic/i_poker_evaluator.dart';
import 'package:card_games/domain/logic/poker_evaluator.dart';
import 'package:card_games/domain/services/i_deck_service.dart';
import 'package:card_games/domain/services/deck_service.dart';
import 'package:card_games/domain/services/i_poker_ai_service.dart';
import 'package:card_games/domain/services/poker_ai_service.dart';
import 'package:card_games/domain/repositories/i_game_repository.dart';
import 'package:card_games/data/repositories/local_game_repository.dart';
import 'package:card_games/domain/logic/card_effects/card_effect_handler.dart';
import 'package:card_games/domain/usecases/apply_card_effect_usecase.dart';
import 'package:card_games/domain/usecases/evaluate_round_usecase.dart';
import 'package:card_games/domain/usecases/execute_ai_turn_usecase.dart';
import 'package:card_games/domain/usecases/get_high_score_usecase.dart';
import 'package:card_games/domain/usecases/play_card_usecase.dart';
import 'package:card_games/domain/usecases/save_high_score_usecase.dart';
import 'package:card_games/domain/usecases/start_new_game_usecase.dart';
import 'package:card_games/domain/usecases/swap_cards_usecase.dart';
import 'package:card_games/domain/models/game_state.dart';
import 'package:card_games/presentation/providers/game_notifier.dart';

final pokerEvaluatorProvider = Provider<IPokerEvaluator>(
  (ref) => PokerEvaluator(),
);

final deckServiceProvider = Provider<IDeckService>((ref) => DeckService());

final aiServiceProvider = Provider<IPokerAiService>((ref) {
  final apiKey = dotenv.env['GEMINI_API_KEY'] ?? '';
  return PokerAiService(apiKey: apiKey);
});

final startNewGameUseCaseProvider = Provider((ref) {
  return StartNewGameUseCase(ref.watch(deckServiceProvider));
});

final swapCardsUseCaseProvider = Provider((ref) {
  return SwapCardsUseCase(ref.watch(deckServiceProvider));
});

final playCardUseCaseProvider = Provider((ref) => PlayCardUseCase());

final cardEffectHandlerProvider = Provider((ref) => CardEffectHandler());

final applyCardEffectUseCaseProvider = Provider((ref) {
  return ApplyCardEffectUseCase(ref.watch(cardEffectHandlerProvider));
});

final evaluateRoundUseCaseProvider = Provider((ref) {
  return EvaluateRoundUseCase(ref.watch(pokerEvaluatorProvider));
});

final executeAiTurnUseCaseProvider = Provider((ref) {
  return ExecuteAiTurnUseCase(
    ref.watch(aiServiceProvider),
  );
});

final gameRepositoryProvider = Provider<IGameRepository>(
  (ref) => LocalGameRepository(),
);

final getHighScoreUseCaseProvider = Provider((ref) {
  return GetHighScoreUseCase(ref.watch(gameRepositoryProvider));
});

final saveHighScoreUseCaseProvider = Provider((ref) {
  return SaveHighScoreUseCase(ref.watch(gameRepositoryProvider));
});

final gameProvider = StateNotifierProvider<GameNotifier, GameState>((ref) {
  return GameNotifier(
    startNewGameUseCase: ref.watch(startNewGameUseCaseProvider),
    swapCardsUseCase: ref.watch(swapCardsUseCaseProvider),
    playCardUseCase: ref.watch(playCardUseCaseProvider),
    evaluateRoundUseCase: ref.watch(evaluateRoundUseCaseProvider),
    executeAiTurnUseCase: ref.watch(executeAiTurnUseCaseProvider),
    applyCardEffectUseCase: ref.watch(applyCardEffectUseCaseProvider),
    getHighScoreUseCase: ref.watch(getHighScoreUseCaseProvider),
    saveHighScoreUseCase: ref.watch(saveHighScoreUseCaseProvider),
    aiService: ref.watch(aiServiceProvider),
    deckService: ref.watch(deckServiceProvider),
    evaluator: ref.watch(pokerEvaluatorProvider),
  );
});
