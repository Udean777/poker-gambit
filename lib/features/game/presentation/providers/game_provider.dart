import 'package:card_games/core/providers/connectivity_provider.dart';
import 'package:card_games/features/auth/presentation/providers/auth_provider.dart';
import 'package:card_games/features/game/data/repositories/firebase_game_repository.dart';
import 'package:card_games/features/game/data/repositories/local_game_repository.dart';
import 'package:card_games/features/game/data/repositories/offline_first_game_repository.dart';
import 'package:card_games/features/game/domain/logic/card_effects/card_effect_handler.dart';
import 'package:card_games/features/game/domain/logic/i_poker_evaluator.dart';
import 'package:card_games/features/game/domain/logic/poker_evaluator.dart';
import 'package:card_games/features/game/domain/models/game_state.dart';
import 'package:card_games/features/game/domain/models/sync_status.dart';
import 'package:card_games/features/game/domain/repositories/i_game_repository.dart';
import 'package:card_games/features/game/domain/services/deck_service.dart';
import 'package:card_games/features/game/domain/services/i_deck_service.dart';
import 'package:card_games/features/game/domain/services/i_poker_ai_service.dart';
import 'package:card_games/features/game/domain/services/local_poker_ai_service.dart';
import 'package:card_games/features/game/domain/usecases/apply_card_effect_usecase.dart';
import 'package:card_games/features/game/domain/usecases/evaluate_round_usecase.dart';
import 'package:card_games/features/game/domain/usecases/execute_ai_turn_usecase.dart';
import 'package:card_games/features/game/domain/usecases/get_stats_usecase.dart';
import 'package:card_games/features/game/domain/usecases/play_card_usecase.dart';
import 'package:card_games/features/game/domain/usecases/save_game_result_usecase.dart';
import 'package:card_games/features/game/domain/usecases/start_new_game_usecase.dart';
import 'package:card_games/features/game/domain/usecases/swap_cards_usecase.dart';
import 'package:card_games/features/game/presentation/providers/game_notifier.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final pokerEvaluatorProvider = Provider<IPokerEvaluator>(
  (ref) => PokerEvaluator(),
);

final deckServiceProvider = Provider<IDeckService>((ref) => DeckService());

final aiServiceProvider = Provider<IPokerAiService>((ref) {
  return LocalPokerAiService(ref.watch(pokerEvaluatorProvider));
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
  return ExecuteAiTurnUseCase(ref.watch(aiServiceProvider));
});

final gameRepositoryProvider = Provider<IGameRepository>((ref) {
  final user = ref.watch(authStateProvider).valueOrNull;
  final connectivity = ref.watch(connectivityServiceProvider);

  if (user == null || user.isGuest) {
    return LocalGameRepository();
  }

  final repo = OfflineFirstGameRepository(
    local: LocalGameRepository(),
    remote: FirebaseGameRepository(
      uid: user.uid,
      displayName: user.displayName,
      photoUrl: user.photoUrl,
    ),
    connectivity: connectivity,
  );

  ref.onDispose(() => repo.dispose());

  return repo;
});

final getStatsUseCaseProvider = Provider((ref) {
  return GetStatsUseCase(ref.watch(gameRepositoryProvider));
});

final saveGameResultUseCaseProvider = Provider((ref) {
  return SaveGameResultUseCase(ref.watch(gameRepositoryProvider));
});

final syncStatusProvider = Provider<SyncStatus>((ref) {
  final isOnline = ref.watch(connectivityProvider).valueOrNull ?? false;
  return isOnline ? SyncStatus.synced : SyncStatus.offline;
});

final gameProvider = StateNotifierProvider<GameNotifier, GameState>((ref) {
  return GameNotifier(
    startNewGameUseCase: ref.watch(startNewGameUseCaseProvider),
    swapCardsUseCase: ref.watch(swapCardsUseCaseProvider),
    playCardUseCase: ref.watch(playCardUseCaseProvider),
    evaluateRoundUseCase: ref.watch(evaluateRoundUseCaseProvider),
    executeAiTurnUseCase: ref.watch(executeAiTurnUseCaseProvider),
    applyCardEffectUseCase: ref.watch(applyCardEffectUseCaseProvider),
    getStatsUseCase: ref.watch(getStatsUseCaseProvider),
    saveGameResultUseCase: ref.watch(saveGameResultUseCaseProvider),
    aiService: ref.watch(aiServiceProvider),
    deckService: ref.watch(deckServiceProvider),
  );
});
