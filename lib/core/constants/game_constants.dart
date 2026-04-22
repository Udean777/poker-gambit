/// Centralized constants for the poker card game.
///
/// Eliminates magic numbers scattered across the codebase,
/// making values easy to find, modify, and test.
class GameConstants {
  GameConstants._(); // Prevent instantiation

  // ─── Game Rules ────────────────────────────────────────────────────
  static const int handSize = 5;
  static const int maxSwapCards = 3;
  static const int minDeckForNewRound = 10;
  static const int maxCardValue = 13;
  static const int jokerRedValue = 1;
  static const int jokerBlackValue = 2;

  // ─── Timing / Delays ──────────────────────────────────────────────
  static const int drawPhaseSeconds = 60;
  static const int playPhaseSeconds = 80;
  static const Duration aiSwapDelay = Duration(milliseconds: 1000);
  static const Duration aiPlayDelay = Duration(milliseconds: 1200);
  static const Duration showdownDelay = Duration(milliseconds: 1500);
  static const Duration nextRoundDelay = Duration(seconds: 4);

  // ─── Animation Durations ──────────────────────────────────────────
  static const Duration discardAnimDuration = Duration(milliseconds: 500);
  static const Duration drawAnimDuration = Duration(milliseconds: 600);
  static const Duration gapCloseDelay = Duration(milliseconds: 400);
  static const Duration overlayEntryDuration = Duration(milliseconds: 600);

  // ─── Card Layout Dimensions ───────────────────────────────────────
  static const double playerCardSpacing = 70.0;
  static const double aiCardSpacing = 60.0;
  static const double cardHandPadding = 20.0;
  static const double cardHeight = 130.0;
  static const double aiCardScale = 0.8;
  static const double aiScaledCardHeight = cardHeight * aiCardScale;
  static const double selectedCardOffset = 30.0;
  static const double miniCardWidth = 90.0;
  static const double miniCardHeight = 130.0;
}
