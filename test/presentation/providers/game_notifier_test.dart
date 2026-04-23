import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:card_games/features/game/domain/models/game_state.dart';
import 'package:card_games/features/game/domain/services/i_poker_ai_service.dart';
import 'package:card_games/features/game/domain/services/i_deck_service.dart';
import 'package:card_games/features/game/domain/logic/i_poker_evaluator.dart';
import 'package:card_games/features/game/domain/usecases/start_new_game_usecase.dart';
import 'package:card_games/features/game/domain/usecases/swap_cards_usecase.dart';
import 'package:card_games/features/game/domain/usecases/play_card_usecase.dart';
import 'package:card_games/features/game/domain/usecases/evaluate_round_usecase.dart';
import 'package:card_games/features/game/domain/usecases/execute_ai_turn_usecase.dart';
import 'package:card_games/features/game/domain/usecases/apply_card_effect_usecase.dart';
import 'package:card_games/features/game/domain/usecases/get_high_score_usecase.dart';
import 'package:card_games/features/game/domain/usecases/save_high_score_usecase.dart';
import 'package:card_games/features/game/presentation/providers/game_notifier.dart';

// Mocks
class MockStartNewGameUseCase extends Mock implements StartNewGameUseCase {}

class MockSwapCardsUseCase extends Mock implements SwapCardsUseCase {}

class MockPlayCardUseCase extends Mock implements PlayCardUseCase {}

class MockEvaluateRoundUseCase extends Mock implements EvaluateRoundUseCase {}

class MockExecuteAiTurnUseCase extends Mock implements ExecuteAiTurnUseCase {}

class MockApplyCardEffectUseCase extends Mock
    implements ApplyCardEffectUseCase {}

class MockGetHighScoreUseCase extends Mock implements GetHighScoreUseCase {}

class MockSaveHighScoreUseCase extends Mock implements SaveHighScoreUseCase {}

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
  late MockGetHighScoreUseCase mockGetHighScore;
  late MockSaveHighScoreUseCase mockSaveHighScore;
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
    mockGetHighScore = MockGetHighScoreUseCase();
    mockSaveHighScore = MockSaveHighScoreUseCase();
    mockAiService = MockPokerAiService();
    mockDeckService = MockDeckService();
    mockEvaluator = MockPokerEvaluator();

    final initialState = const GameState(
      deck: [],
      playerHand: [],
      aiHand: [],
      highScore: 100,
    );

    when(() => mockGetHighScore.execute()).thenAnswer((_) async => 100);
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
      getHighScoreUseCase: mockGetHighScore,
      saveHighScoreUseCase: mockSaveHighScore,
      aiService: mockAiService,
      deckService: mockDeckService,
      evaluator: mockEvaluator,
    );
  });

  group('GameNotifier', () {
    test('initial state should load high score and start game', () async {
      // Need to wait for _init() which is called in constructor
      await Future.delayed(Duration.zero);

      expect(notifier.state.highScore, 100);
      verify(() => mockGetHighScore.execute()).called(1);
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
      notifier.toggleCardSelection(3); // Should not be added (max 3)

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
