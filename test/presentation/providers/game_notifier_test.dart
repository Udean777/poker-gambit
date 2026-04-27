import 'package:poker_gambit/features/game/domain/logic/i_poker_evaluator.dart';
import 'package:poker_gambit/features/game/domain/models/game_state.dart';
import 'package:poker_gambit/features/game/domain/models/game_stats.dart';
import 'package:poker_gambit/features/game/domain/services/i_poker_ai_service.dart';
import 'package:poker_gambit/features/game/domain/services/i_deck_service.dart';
import 'package:poker_gambit/features/game/domain/usecases/start_new_game_usecase.dart';
import 'package:poker_gambit/features/game/domain/usecases/swap_cards_usecase.dart';
import 'package:poker_gambit/features/game/domain/usecases/play_card_usecase.dart';
import 'package:poker_gambit/features/game/domain/usecases/evaluate_round_usecase.dart';
import 'package:poker_gambit/features/game/domain/usecases/execute_ai_turn_usecase.dart';
import 'package:poker_gambit/features/game/domain/usecases/apply_card_effect_usecase.dart';
import 'package:poker_gambit/features/game/domain/usecases/get_stats_usecase.dart';
import 'package:poker_gambit/features/game/domain/usecases/save_game_result_usecase.dart';
import 'package:poker_gambit/features/game/presentation/providers/game_notifier.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockStartNewGameUseCase extends Mock implements StartNewGameUseCase {}

class MockSwapCardsUseCase extends Mock implements SwapCardsUseCase {}

class MockPlayCardUseCase extends Mock implements PlayCardUseCase {}

class MockEvaluateRoundUseCase extends Mock implements EvaluateRoundUseCase {}

class MockExecuteAiTurnUseCase extends Mock implements ExecuteAiTurnUseCase {}

class MockApplyCardEffectUseCase extends Mock
    implements ApplyCardEffectUseCase {}

class MockGetStatsUseCase extends Mock implements GetStatsUseCase {}

class MockSaveGameResultUseCase extends Mock implements SaveGameResultUseCase {}

class MockPokerAiService extends Mock implements IPokerAiService {}

class MockDeckService extends Mock implements IDeckService {}

class MockPokerEvaluator extends Mock implements IPokerEvaluator {}

void main() {
  late GameNotifier notifier;
  late MockStartNewGameUseCase mockStartNewGame;
  late MockSwapCardsUseCase mockSwapCards;
  late MockPlayCardUseCase mockPlayCard;
  late MockEvaluateRoundUseCase mockEvaluateRound;
  late MockExecuteAiTurnUseCase mockExecuteAiTurn;
  late MockApplyCardEffectUseCase mockApplyCardEffect;
  late MockGetStatsUseCase mockGetStats;
  late MockSaveGameResultUseCase mockSaveGameResult;
  late MockPokerAiService mockAiService;
  late MockDeckService mockDeckService;
  late MockPokerEvaluator mockEvaluator;

  setUp(() {
    mockStartNewGame = MockStartNewGameUseCase();
    mockSwapCards = MockSwapCardsUseCase();
    mockPlayCard = MockPlayCardUseCase();
    mockEvaluateRound = MockEvaluateRoundUseCase();
    mockExecuteAiTurn = MockExecuteAiTurnUseCase();
    mockApplyCardEffect = MockApplyCardEffectUseCase();
    mockGetStats = MockGetStatsUseCase();
    mockSaveGameResult = MockSaveGameResultUseCase();
    mockAiService = MockPokerAiService();
    mockDeckService = MockDeckService();
    mockEvaluator = MockPokerEvaluator();

    final initialState = const GameState(
      deck: [],
      playerHand: [],
      aiHand: [],
      highScore: 100,
    );

    when(
      () => mockGetStats(),
    ).thenAnswer((_) async => const GameStats(highScore: 100));
    when(
      () => mockStartNewGame.execute(highScore: any(named: 'highScore')),
    ).thenReturn(initialState);

    notifier = GameNotifier(
      startNewGameUseCase: mockStartNewGame,
      swapCardsUseCase: mockSwapCards,
      playCardUseCase: mockPlayCard,
      evaluateRoundUseCase: mockEvaluateRound,
      executeAiTurnUseCase: mockExecuteAiTurn,
      applyCardEffectUseCase: mockApplyCardEffect,
      getStatsUseCase: mockGetStats,
      saveGameResultUseCase: mockSaveGameResult,
      aiService: mockAiService,
      deckService: mockDeckService,
      evaluator: mockEvaluator,
    );
  });

  group('GameNotifier', () {
    test('initial state should load stats and start game', () async {
      await Future.delayed(Duration.zero);

      expect(notifier.state.highScore, 100);
      verify(() => mockGetStats()).called(1);
      verify(
        () => mockStartNewGame.execute(highScore: any(named: 'highScore')),
      ).called(1);
    });

    test('toggleCardSelection should add/remove indices', () {
      notifier.toggleCardSelection(0);
      expect(notifier.state.selectedIndices, [0]);

      notifier.toggleCardSelection(0);
      expect(notifier.state.selectedIndices, isEmpty);
    });

    test('toggleCardSelection should respect max selection', () {
      notifier.toggleCardSelection(0);
      notifier.toggleCardSelection(1);
      notifier.toggleCardSelection(2);
      notifier.toggleCardSelection(3);

      expect(notifier.state.selectedIndices.length, 3);
      expect(notifier.state.selectedIndices, [0, 1, 2]);
    });

    test('togglePause should flip isPaused state', () {
      expect(notifier.state.isPaused, isFalse);
      notifier.togglePause();
      expect(notifier.state.isPaused, isTrue);
    });
  });
}
