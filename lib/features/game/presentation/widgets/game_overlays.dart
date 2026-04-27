import 'package:poker_gambit/core/theme/game_theme.dart';
import 'package:poker_gambit/features/game/domain/models/card_model.dart';
import 'package:poker_gambit/features/game/domain/models/round_result_info.dart';
import 'package:poker_gambit/features/game/presentation/providers/game_notifier.dart';
import 'package:poker_gambit/features/game/presentation/widgets/playing_card.dart';
import 'package:flutter/material.dart';

class PauseOverlay extends StatelessWidget {
  final GameNotifier gameLogic;
  final VoidCallback onExitToMenu;

  const PauseOverlay({
    super.key,
    required this.gameLogic,
    required this.onExitToMenu,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withValues(alpha: 0.7),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.pause_circle_filled,
              color: Colors.white,
              size: 80,
            ),
            const SizedBox(height: 20),
            const Text(
              'GAME PAUSED',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
                letterSpacing: 4,
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: GameTheme.accentAmber,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 15,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              onPressed: gameLogic.togglePause,
              child: const Text('RESUME'),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: onExitToMenu,
              child: const Text(
                'EXIT TO MENU',
                style: TextStyle(color: Colors.white70),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class WitchSelectionOverlay extends StatefulWidget {
  final List<CardModel> options;
  final bool isPlayerPicking;
  final Function(CardModel) onSelected;

  const WitchSelectionOverlay({
    super.key,
    required this.options,
    required this.isPlayerPicking,
    required this.onSelected,
  });

  @override
  State<WitchSelectionOverlay> createState() => _WitchSelectionOverlayState();
}

class _WitchSelectionOverlayState extends State<WitchSelectionOverlay> {
  int? _highlightedIndex;

  @override
  void initState() {
    super.initState();
    if (!widget.isPlayerPicking) {
      _startAiThinkingAnimation();
    }
  }

  Future<void> _startAiThinkingAnimation() async {
    for (int i = 0; i < 8; i++) {
      if (!mounted) return;
      setState(() {
        _highlightedIndex = i % widget.options.length;
      });
      await Future.delayed(const Duration(milliseconds: 250));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withValues(alpha: 0.85),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.isPlayerPicking ? "WITCH SELECTION" : "AI IS THINKING...",
              style: const TextStyle(
                color: GameTheme.accentAmber,
                fontSize: 28,
                fontWeight: FontWeight.bold,
                letterSpacing: 4,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              widget.isPlayerPicking
                  ? "Pilih 1 kartu untuk menyabotase lawan!"
                  : "AI sedang mencari kartu terburuk untuk Anda...",
              style: const TextStyle(color: Colors.white70, fontSize: 16),
            ),
            const SizedBox(height: 50),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: List.generate(widget.options.length, (index) {
                  final card = widget.options[index];
                  final isHighlighted = _highlightedIndex == index;

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: GestureDetector(
                      onTap: widget.isPlayerPicking
                          ? () => widget.onSelected(card)
                          : null,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                        transform: Matrix4.identity()
                          // ignore: deprecated_member_use
                          ..scale(
                            isHighlighted ? 1.15 : 1.0,
                            isHighlighted ? 1.15 : 1.0,
                          ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: isHighlighted
                              ? [
                                  BoxShadow(
                                    color: GameTheme.accentAmber.withValues(
                                      alpha: 0.6,
                                    ),
                                    blurRadius: 20,
                                    spreadRadius: 5,
                                  ),
                                ]
                              : [],
                        ),
                        child: PlayingCard(
                          card: card.copyWith(isFaceUp: true),
                          height: 180,
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
            const SizedBox(height: 60),
            if (widget.isPlayerPicking)
              const Text(
                "Ketuk salah satu kartu di atas",
                style: TextStyle(
                  color: Colors.white54,
                  fontStyle: FontStyle.italic,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class SpySelectionOverlay extends StatefulWidget {
  final List<CardModel> options;
  final bool isPlayerPicking;
  final Function(CardModel) onSelected;
  final CardModel? selectedCard;

  const SpySelectionOverlay({
    super.key,
    required this.options,
    required this.isPlayerPicking,
    required this.onSelected,
    this.selectedCard,
  });

  @override
  State<SpySelectionOverlay> createState() => _SpySelectionOverlayState();
}

class _SpySelectionOverlayState extends State<SpySelectionOverlay> {
  int? _highlightedIndex;

  @override
  void initState() {
    super.initState();
    if (!widget.isPlayerPicking && widget.selectedCard == null) {
      _startAiPeekingAnimation();
    }
  }

  Future<void> _startAiPeekingAnimation() async {
    for (int i = 0; i < 6; i++) {
      if (!mounted) return;
      setState(() {
        _highlightedIndex = i % widget.options.length;
      });
      await Future.delayed(const Duration(milliseconds: 300));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withValues(alpha: 0.9),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.security, color: Colors.blueAccent, size: 32),
                const SizedBox(width: 15),
                Text(
                  widget.isPlayerPicking
                      ? "SPY: INVESTIGATING"
                      : "AI IS PEEKING...",
                  style: const TextStyle(
                    color: Colors.blueAccent,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 4,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              widget.isPlayerPicking
                  ? (widget.selectedCard == null
                        ? "Ketuk satu kartu lawan untuk melihat detailnya!"
                        : "Informasi intelijen didapatkan!")
                  : "AI sedang menganalisis titik lemah kartu Anda...",
              style: const TextStyle(color: Colors.white70, fontSize: 16),
            ),
            const SizedBox(height: 50),
            if (widget.selectedCard == null)
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(widget.options.length, (index) {
                    final isHighlighted = _highlightedIndex == index;
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: GestureDetector(
                        onTap: widget.isPlayerPicking
                            ? () => widget.onSelected(widget.options[index])
                            : null,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          transform: Matrix4.identity()
                            // ignore: deprecated_member_use
                            ..scale(isHighlighted ? 1.1 : 1.0),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: isHighlighted
                                ? [
                                    BoxShadow(
                                      color: Colors.blueAccent.withValues(
                                        alpha: 0.5,
                                      ),
                                      blurRadius: 15,
                                      spreadRadius: 2,
                                    ),
                                  ]
                                : [],
                          ),
                          child: PlayingCard(
                            card: widget.options[index].copyWith(
                              isFaceUp: false,
                            ),
                            height: 160,
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              )
            else
              _DetailedCardView(card: widget.selectedCard!),
            const SizedBox(height: 40),
            if (widget.selectedCard != null) const _SpyTimerIndicator(),
          ],
        ),
      ),
    );
  }
}

class _DetailedCardView extends StatelessWidget {
  final CardModel card;

  const _DetailedCardView({required this.card});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 600),
      curve: Curves.elasticOut,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blueAccent.withValues(alpha: 0.3),
                      blurRadius: 40,
                      spreadRadius: 10,
                    ),
                  ],
                ),
                child: PlayingCard(
                  card: card.copyWith(isFaceUp: true),
                  height: 280,
                ),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.blueAccent.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.blueAccent.withValues(alpha: 0.4),
                  ),
                ),
                child: Text(
                  "${card.valueLabel} of ${card.suit.name.toUpperCase()}",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SpyTimerIndicator extends StatefulWidget {
  const _SpyTimerIndicator();

  @override
  State<_SpyTimerIndicator> createState() => _SpyTimerIndicatorState();
}

class _SpyTimerIndicatorState extends State<_SpyTimerIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: 200,
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return LinearProgressIndicator(
                value: 1.0 - _controller.value,
                backgroundColor: Colors.white10,
                color: Colors.blueAccent,
                minHeight: 6,
                borderRadius: BorderRadius.circular(3),
              );
            },
          ),
        ),
        const SizedBox(height: 10),
        const Text(
          "REVEALING DATA...",
          style: TextStyle(
            color: Colors.blueAccent,
            fontSize: 12,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
      ],
    );
  }
}

class DestroySelectionOverlay extends StatefulWidget {
  final List<CardModel> options;
  final bool isPlayerPicking;
  final Function(CardModel) onSelected;
  final CardModel? cardBeingDestroyed;

  const DestroySelectionOverlay({
    super.key,
    required this.options,
    required this.isPlayerPicking,
    required this.onSelected,
    this.cardBeingDestroyed,
  });

  @override
  State<DestroySelectionOverlay> createState() =>
      _DestroySelectionOverlayState();
}

class _DestroySelectionOverlayState extends State<DestroySelectionOverlay> {
  CardModel? _hoveredCard;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withValues(alpha: 0.9),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.whatshot,
                  color: Colors.orangeAccent,
                  size: 32,
                ),
                const SizedBox(width: 15),
                Text(
                  widget.isPlayerPicking
                      ? "JOKER: DESTROYER"
                      : "AI IS TARGETING...",
                  style: const TextStyle(
                    color: Colors.orangeAccent,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 4,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              widget.isPlayerPicking
                  ? (widget.cardBeingDestroyed == null
                        ? "Pilih satu kartu lawan untuk dihancurkan selamanya!"
                        : "Target dikunci. Menghancurkan...")
                  : "AI sedang membakar strategi Anda...",
              style: const TextStyle(color: Colors.white70, fontSize: 16),
            ),
            const SizedBox(height: 50),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: List.generate(widget.options.length, (index) {
                  final card = widget.options[index];
                  final isTargeted = widget.cardBeingDestroyed == card;
                  final isHovered = _hoveredCard == card;

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: GestureDetector(
                      onTap:
                          widget.isPlayerPicking &&
                              widget.cardBeingDestroyed == null
                          ? () => widget.onSelected(card)
                          : null,
                      child: MouseRegion(
                        onEnter: (_) => setState(() => _hoveredCard = card),
                        onExit: (_) => setState(() => _hoveredCard = null),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            AnimatedOpacity(
                              duration: const Duration(milliseconds: 300),
                              opacity: isTargeted ? 0.0 : 1.0,
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: isHovered
                                      ? [
                                          BoxShadow(
                                            color: Colors.orangeAccent
                                                .withValues(alpha: 0.5),
                                            blurRadius: 20,
                                            spreadRadius: 5,
                                          ),
                                        ]
                                      : [],
                                ),
                                child: PlayingCard(
                                  card: card.copyWith(isFaceUp: true),
                                  height: 180,
                                ),
                              ),
                            ),
                            if (isTargeted) const BurningCardEffect(),
                            if (widget.isPlayerPicking &&
                                widget.cardBeingDestroyed == null &&
                                isHovered)
                              const _TargetReticle(),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
            const SizedBox(height: 60),
          ],
        ),
      ),
    );
  }
}

class _TargetReticle extends StatelessWidget {
  const _TargetReticle();

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 1.5, end: 1.0),
      duration: const Duration(milliseconds: 300),
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.orangeAccent, width: 2),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Icon(Icons.close, color: Colors.orangeAccent, size: 40),
            ),
          ),
        );
      },
    );
  }
}

class BurningCardEffect extends StatefulWidget {
  const BurningCardEffect({super.key});

  @override
  State<BurningCardEffect> createState() => _BurningCardEffectState();
}

class _BurningCardEffectState extends State<BurningCardEffect>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final progress = _controller.value;
        return SizedBox(
          width: 90,
          height: 130,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // Particles / Fire effect
              ...List.generate(25, (index) {
                final randomX = ((index * 45) % 100) - 50;
                final randomY =
                    -progress * 200 * (0.6 + ((index * 7) % 10) / 10.0);

                return Positioned(
                  bottom: 65,
                  left: 45 + randomX * progress,
                  child: Opacity(
                    opacity: (1.0 - progress),
                    child: Transform.translate(
                      offset: Offset(0, randomY),
                      child: Container(
                        width: 12 * (1.0 - progress),
                        height: 12 * (1.0 - progress),
                        decoration: BoxDecoration(
                          color: index % 3 == 0
                              ? Colors.orange
                              : (index % 3 == 1 ? Colors.red : Colors.yellow),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.orangeAccent.withValues(alpha: 0.8),
                              blurRadius: 10,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }),
              // The card "dissolving"
              Center(
                child: Opacity(
                  opacity: (1.0 - progress),
                  child: Transform.scale(
                    scale: 1.0 + progress * 0.3,
                    child: Container(
                      width: 90,
                      height: 130,
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.orangeAccent.withValues(
                              alpha: 0.7 * (1.0 - progress),
                            ),
                            blurRadius: 30 * progress,
                            spreadRadius: 10 * progress,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class WildcardNotification extends StatelessWidget {
  final String rankName;

  const WildcardNotification({super.key, required this.rankName});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 150,
      left: 0,
      right: 0,
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.0, end: 1.0),
        duration: const Duration(milliseconds: 800),
        curve: Curves.elasticOut,
        builder: (context, value, child) {
          return Opacity(
            opacity: value.clamp(0.0, 1.0),
            child: Transform.translate(
              offset: Offset(0, 50 * (1 - value)),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 30,
                    vertical: 15,
                  ),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Colors.purple, Colors.blueAccent, Colors.purple],
                    ),
                    borderRadius: BorderRadius.circular(40),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blueAccent.withValues(alpha: 0.5),
                        blurRadius: 30,
                        spreadRadius: 5,
                      ),
                    ],
                    border: Border.all(color: Colors.white30, width: 2),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const _AnimatedStarIcon(),
                      const SizedBox(width: 15),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "WILDCARD TRANSFORM!",
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 2,
                            ),
                          ),
                          Text(
                            rankName.toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 3,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 15),
                      const _AnimatedStarIcon(),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _AnimatedStarIcon extends StatefulWidget {
  const _AnimatedStarIcon();

  @override
  State<_AnimatedStarIcon> createState() => _AnimatedStarIconState();
}

class _AnimatedStarIconState extends State<_AnimatedStarIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: Tween(
        begin: 0.8,
        end: 1.2,
      ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut)),
      child: const Icon(Icons.stars, color: Colors.amber, size: 30),
    );
  }
}

class RoundResultOverlay extends StatelessWidget {
  final RoundResultInfo result;
  final VoidCallback onDismiss;

  const RoundResultOverlay({
    super.key,
    required this.result,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final isWin = result.isPlayerWinner == true;
    final isDraw = result.isPlayerWinner == null;

    return Container(
      color: Colors.black.withValues(alpha: 0.95),
      child: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _ResultHeader(isWin: isWin, isDraw: isDraw),
              const SizedBox(height: 40),
              _BattleArea(result: result),
              const SizedBox(height: 50),
              _ContinueButton(onDismiss: onDismiss),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class _ResultHeader extends StatelessWidget {
  final bool isWin;
  final bool isDraw;

  const _ResultHeader({required this.isWin, required this.isDraw});

  @override
  Widget build(BuildContext context) {
    String title = isWin ? "VICTORY" : (isDraw ? "DRAW" : "DEFEAT");
    Color color = isWin
        ? Colors.amber
        : (isDraw ? Colors.blueGrey : Colors.redAccent);
    IconData icon = isWin
        ? Icons.emoji_events
        : (isDraw ? Icons.balance : Icons.sentiment_very_dissatisfied);

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 800),
      curve: Curves.elasticOut,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: Column(
            children: [
              Icon(icon, color: color, size: 80),
              const SizedBox(height: 10),
              Text(
                title,
                style: TextStyle(
                  color: color,
                  fontSize: 48,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 8,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _BattleArea extends StatelessWidget {
  final RoundResultInfo result;

  const _BattleArea({required this.result});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _HandDisplay(
            label: "YOU",
            handName: result.playerHandName,
            cards: result.playerTableCards,
            isWinner: result.isPlayerWinner == true,
            color: Colors.blueAccent,
          ),
          const Text(
            "VS",
            style: TextStyle(
              color: Colors.white24,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          _HandDisplay(
            label: "AI",
            handName: result.aiHandName,
            cards: result.aiTableCards,
            isWinner: result.isPlayerWinner == false,
            color: Colors.redAccent,
          ),
        ],
      ),
    );
  }
}

class _HandDisplay extends StatelessWidget {
  final String label;
  final String handName;
  final List<CardModel> cards;
  final bool isWinner;
  final Color color;

  const _HandDisplay({
    required this.label,
    required this.handName,
    required this.cards,
    required this.isWinner,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            color: color.withValues(alpha: 0.7),
            fontSize: 16,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isWinner ? color : Colors.transparent,
              width: 3,
            ),
            boxShadow: isWinner
                ? [
                    BoxShadow(
                      color: color.withValues(alpha: 0.3),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ]
                : [],
          ),
          child: Column(
            children: [
              Wrap(
                spacing: -40,
                children: cards
                    .map(
                      (c) => Transform.scale(
                        scale: 0.7,
                        child: PlayingCard(card: c.copyWith(isFaceUp: true)),
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 15),
              Text(
                handName.toUpperCase(),
                style: TextStyle(
                  color: isWinner ? color : Colors.white70,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
        ),
        if (isWinner) ...[
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Text(
              "WINNER",
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _ContinueButton extends StatelessWidget {
  final VoidCallback onDismiss;

  const _ContinueButton({required this.onDismiss});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onDismiss,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        elevation: 10,
      ),
      child: const Text(
        "CONTINUE",
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          letterSpacing: 2,
        ),
      ),
    );
  }
}
