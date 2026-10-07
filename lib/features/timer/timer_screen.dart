import 'package:flutter/material.dart';

import '../../app/theme/colors.dart';
import '../../l10n/app_localizations.dart';
import 'controllers/timer_controller.dart';
import 'widgets/circular_timer.dart';
import 'widgets/mode_selector.dart';
import 'widgets/time_selector.dart';

class TimerScreen extends StatefulWidget {
  const TimerScreen({super.key});

  @override
  State<TimerScreen> createState() => _TimerScreenState();
}

class _TimerScreenState extends State<TimerScreen> {
  late final TimerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TimerController();
    _controller.addListener(_onStateChanged);
  }

  @override
  void dispose() {
    _controller.removeListener(_onStateChanged);
    _controller.dispose();
    super.dispose();
  }

  void _onStateChanged() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final state = _controller.state;

    return Scaffold(
      backgroundColor: AppColors.paper,
      appBar: AppBar(
        title: Text(l10n.timerTitle),
        backgroundColor: AppColors.paper,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            CircularTimer(state: state),
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: ModeSelector(
                    selectedMode: state.mode,
                    onModeChanged: _controller.setMode,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TimeSelector(
                    selectedBlock: state.block,
                    onBlockChanged: _controller.setBlock,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FilledButton(
                  onPressed: state.status == TimerStatus.running
                      ? null
                      : () {
                          if (state.status == TimerStatus.paused) {
                            _controller.resume();
                          } else {
                            _controller.start();
                          }
                        },
                  child: Text(
                    state.status == TimerStatus.paused
                        ? l10n.timerResume
                        : l10n.timerStart,
                  ),
                ),
                const SizedBox(width: 16),
                OutlinedButton(
                  onPressed: state.status == TimerStatus.running
                      ? _controller.pause
                      : null,
                  child: Text(l10n.timerPause),
                ),
                const SizedBox(width: 16),
                TextButton(
                  onPressed: _controller.reset,
                  child: Text(l10n.timerReset),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
