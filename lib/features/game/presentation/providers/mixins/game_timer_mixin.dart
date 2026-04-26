import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:card_games/features/game/domain/models/game_state.dart';

mixin GameTimerMixin on StateNotifier<GameState> {
  Timer? _turnTimer;

  void startTimer(int seconds, {required VoidCallback onTimeout}) {
    _turnTimer?.cancel();
    state = state.copyWith(timeLeft: seconds);
    _turnTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (state.isPaused) return;

      if (state.timeLeft > 1) {
        state = state.copyWith(timeLeft: state.timeLeft - 1);
      } else {
        timer.cancel();
        state = state.copyWith(timeLeft: 0);
        onTimeout();
      }
    });
  }

  void cancelTimer() {
    _turnTimer?.cancel();
    _turnTimer = null;
    if (mounted) state = state.copyWith(timeLeft: 0);
  }

  @override
  void dispose() {
    _turnTimer?.cancel();
    super.dispose();
  }
}
