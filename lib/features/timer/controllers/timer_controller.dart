import 'dart:async';

import 'package:flutter/material.dart';

import '../models/timer_mode.dart';
import '../models/timer_phase.dart';
import '../models/timer_sequence.dart';

enum TimerStatus {
  idle,
  running,
  paused,
  finished,
}

class TimerState {
  const TimerState({
    required this.status,
    required this.mode,
    required this.block,
    required this.phases,
    required this.currentPhaseIndex,
    required this.remainingSeconds,
    required this.totalSeconds,
  });

  final TimerStatus status;
  final TimerMode mode;
  final int block;
  final List<TimerPhase> phases;
  final int currentPhaseIndex;
  final int remainingSeconds;
  final int totalSeconds;

  TimerPhase? get currentPhase {
    if (currentPhaseIndex < 0 || currentPhaseIndex >= phases.length) {
      return null;
    }
    return phases[currentPhaseIndex];
  }

  double get progress {
    if (totalSeconds <= 0) return 1.0;
    final elapsed = totalSeconds - remainingSeconds;
    return (elapsed / totalSeconds).clamp(0.0, 1.0);
  }

  TimerState copyWith({
    TimerStatus? status,
    TimerMode? mode,
    int? block,
    List<TimerPhase>? phases,
    int? currentPhaseIndex,
    int? remainingSeconds,
    int? totalSeconds,
  }) {
    return TimerState(
      status: status ?? this.status,
      mode: mode ?? this.mode,
      block: block ?? this.block,
      phases: phases ?? this.phases,
      currentPhaseIndex: currentPhaseIndex ?? this.currentPhaseIndex,
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
      totalSeconds: totalSeconds ?? this.totalSeconds,
    );
  }
}

class TimerController extends ChangeNotifier {
  TimerController()
      : _state = _initialState();

  static TimerState _initialState() {
    final sequence = TimerSequence(mode: TimerMode.work, block: 25);
    final phases = sequence.generate();
    return TimerState(
      status: TimerStatus.idle,
      mode: TimerMode.work,
      block: 25,
      phases: phases,
      currentPhaseIndex: 0,
      remainingSeconds: phases.isNotEmpty ? phases[0].durationSeconds : 0,
      totalSeconds: phases.isNotEmpty ? phases[0].durationSeconds : 0,
    );
  }

  TimerState _state;
  Timer? _timer;

  TimerState get state => _state;

  void _update(TimerState newState) {
    _state = newState;
    notifyListeners();
  }

  void start() {
    if (_state.status == TimerStatus.running) return;
    if (_state.status == TimerStatus.finished) {
      _resetToCurrentConfig();
    }
    _update(_state.copyWith(status: TimerStatus.running));
    _startTimer();
  }

  void pause() {
    if (_state.status != TimerStatus.running) return;
    _timer?.cancel();
    _timer = null;
    _update(_state.copyWith(status: TimerStatus.paused));
  }

  void resume() {
    if (_state.status != TimerStatus.paused) return;
    _update(_state.copyWith(status: TimerStatus.running));
    _startTimer();
  }

  void reset() {
    _timer?.cancel();
    _timer = null;
    _resetToCurrentConfig();
  }

  void setMode(TimerMode mode) {
    if (_state.mode == mode && _state.status != TimerStatus.finished) {
      // Allow change even if same? but spec says restart on change
    }
    _timer?.cancel();
    _timer = null;
    final sequence = TimerSequence(mode: mode, block: _state.block);
    final phases = sequence.generate();
    _update(
      TimerState(
        status: TimerStatus.idle,
        mode: mode,
        block: _state.block,
        phases: phases,
        currentPhaseIndex: 0,
        remainingSeconds: phases.isNotEmpty ? phases[0].durationSeconds : 0,
        totalSeconds: phases.isNotEmpty ? phases[0].durationSeconds : 0,
      ),
    );
  }

  void setBlock(int block) {
    if (_state.block == block) {
      // restart anyway
    }
    _timer?.cancel();
    _timer = null;
    final sequence = TimerSequence(mode: _state.mode, block: block);
    final phases = sequence.generate();
    _update(
      TimerState(
        status: TimerStatus.idle,
        mode: _state.mode,
        block: block,
        phases: phases,
        currentPhaseIndex: 0,
        remainingSeconds: phases.isNotEmpty ? phases[0].durationSeconds : 0,
        totalSeconds: phases.isNotEmpty ? phases[0].durationSeconds : 0,
      ),
    );
  }

  void _resetToCurrentConfig() {
    final sequence = TimerSequence(mode: _state.mode, block: _state.block);
    final phases = sequence.generate();
    _update(
      _state.copyWith(
        status: TimerStatus.idle,
        phases: phases,
        currentPhaseIndex: 0,
        remainingSeconds: phases.isNotEmpty ? phases[0].durationSeconds : 0,
        totalSeconds: phases.isNotEmpty ? phases[0].durationSeconds : 0,
      ),
    );
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      _tick();
    });
  }

  void _tick() {
    final current = _state.remainingSeconds;
    if (current <= 1) {
      _advanceToNextPhase();
    } else {
      _update(_state.copyWith(remainingSeconds: current - 1));
    }
  }

  void _advanceToNextPhase() {
    final nextIndex = _state.currentPhaseIndex + 1;
    if (nextIndex < _state.phases.length) {
      // Move to next phase in same sequence
      final nextPhase = _state.phases[nextIndex];
      _update(
        _state.copyWith(
          currentPhaseIndex: nextIndex,
          remainingSeconds: nextPhase.durationSeconds,
          totalSeconds: nextPhase.durationSeconds,
        ),
      );
    } else {
      // Sequence completed
      final seq = TimerSequence(mode: _state.mode, block: _state.block);
      seq.onCompleted();
      // Check if completed was block 90 - transition to block 45
      if (_state.block == 90) {
        _transitionAfter90();
      } else {
        // Completed block 25 or 45 - restart same block/mode
        _timer?.cancel();
        _timer = null;
        final newSeq = TimerSequence(mode: _state.mode, block: _state.block);
        final phases = newSeq.generate();
        _update(
          _state.copyWith(
            status: TimerStatus.idle,
            phases: phases,
            currentPhaseIndex: 0,
            remainingSeconds: phases.isNotEmpty ? phases[0].durationSeconds : 0,
            totalSeconds: phases.isNotEmpty ? phases[0].durationSeconds : 0,
          ),
        );
      }
    }
  }

  void _transitionAfter90() {
    // After completing 90, go to block 45 with same mode, continuing cycle
    _timer?.cancel();
    _timer = null;
    final nextBlock = 45;
    final sequence = TimerSequence(mode: _state.mode, block: nextBlock);
    final phases = sequence.generate();
    _update(
      TimerState(
        status: TimerStatus.idle,
        mode: _state.mode,
        block: nextBlock,
        phases: phases,
        currentPhaseIndex: 0,
        remainingSeconds: phases.isNotEmpty ? phases[0].durationSeconds : 0,
        totalSeconds: phases.isNotEmpty ? phases[0].durationSeconds : 0,
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
