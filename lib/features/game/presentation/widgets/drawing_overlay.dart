import 'package:flutter/material.dart';

/// Floating overlay shown during card swap phases.
///
/// Displays the swap/skip button and a badge showing the number
/// of selected cards. Disables interaction while [onExecute] is null.
class DrawingOverlay extends StatelessWidget {
  final int selectedCount;
  final Future<void> Function()? onExecute;
  final bool isMidGame;

  const DrawingOverlay({
    super.key,
    required this.selectedCount,
    required this.onExecute,
    this.isMidGame = false,
  });

  bool get _isButtonEnabled {
    if (onExecute == null) return false;
    return selectedCount > 0 || !isMidGame;
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 175,
      right: 20,
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: 1),
        duration: const Duration(milliseconds: 600),
        curve: Curves.elasticOut,
        builder: (context, value, child) {
          return Transform.scale(
            scale: value,
            child: Opacity(opacity: value.clamp(0.0, 1.0), child: child),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (selectedCount > 0) _buildSelectionBadge(),
            _buildActionButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectionBadge() {
    return Container(
      margin: const EdgeInsets.only(bottom: 8, right: 4),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.amber,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [BoxShadow(color: Colors.black45, blurRadius: 4)],
      ),
      child: Text(
        "$selectedCount KARTU",
        style: const TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.bold,
          fontSize: 10,
        ),
      ),
    );
  }

  Widget _buildActionButton() {
    final hasSelection = selectedCount > 0;

    return SizedBox(
      height: 50,
      child: FloatingActionButton.extended(
        onPressed: _isButtonEnabled ? () => onExecute!() : null,
        backgroundColor: hasSelection ? Colors.amber : Colors.black87,
        foregroundColor: hasSelection ? Colors.black : Colors.white70,
        elevation: 6,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25),
          side: BorderSide(
            color: Colors.amber.withValues(alpha: 0.5),
            width: 1,
          ),
        ),
        label: Text(
          hasSelection ? "TUKAR" : (isMidGame ? "NANTI" : "LEWATI"),
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 12,
            letterSpacing: 1,
          ),
        ),
        icon: Icon(hasSelection ? Icons.swap_horiz : Icons.forward, size: 20),
      ),
    );
  }
}
