import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/app_utils.dart';
import '../../data/providers/app_provider.dart';
import '../../shared/widgets/shared_widgets.dart';

enum TimerMode { focus, shortBreak, longBreak }

class TimerScreen extends StatefulWidget {
  const TimerScreen({super.key});

  @override
  State<TimerScreen> createState() => _TimerScreenState();
}

class _TimerScreenState extends State<TimerScreen>
    with TickerProviderStateMixin {
  TimerMode _mode = TimerMode.focus;
  bool _running = false;
  int _seconds = 25 * 60;
  int _totalSeconds = 25 * 60;
  Timer? _timer;
  int _sessionsCompleted = 0;
  String _subject = 'General';
  late AnimationController _pulseController;

  final Map<TimerMode, int> _durations = {
    TimerMode.focus: 25 * 60,
    TimerMode.shortBreak: 5 * 60,
    TimerMode.longBreak: 15 * 60,
  };

  final Map<TimerMode, String> _labels = {
    TimerMode.focus: 'Focus',
    TimerMode.shortBreak: 'Short Break',
    TimerMode.longBreak: 'Long Break',
  };

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  void _setMode(TimerMode mode) {
    if (_running) return;
    setState(() {
      _mode = mode;
      _seconds = _durations[mode]!;
      _totalSeconds = _durations[mode]!;
    });
  }

  void _toggle() {
    if (_running) {
      _timer?.cancel();
      setState(() => _running = false);
    } else {
      setState(() => _running = true);
      _timer = Timer.periodic(const Duration(seconds: 1), (_) {
        if (_seconds <= 0) {
          _timer?.cancel();
          setState(() {
            _running = false;
            if (_mode == TimerMode.focus) {
              _sessionsCompleted++;
              _onFocusComplete();
            }
          });
        } else {
          setState(() => _seconds--);
        }
      });
    }
  }

  void _reset() {
    _timer?.cancel();
    setState(() {
      _running = false;
      _seconds = _durations[_mode]!;
      _totalSeconds = _durations[_mode]!;
    });
  }

  void _onFocusComplete() {
    final provider = context.read<AppProvider>();
    final minutes = _durations[TimerMode.focus]! ~/ 60;
    provider.recordStudySession(minutes, _subject);
    _showCompletionDialog();
  }

  void _showCompletionDialog() {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: AppColors.navySurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('🎉', style: TextStyle(fontSize: 48)),
              const SizedBox(height: 16),
              const Text(
                'Session Complete!',
                style: TextStyle(
                  
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                  fontSize: 22,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '+50 XP earned! Session $_sessionsCompleted done.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  
                  color: AppColors.textSecondary,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 24),
              GradientButton(
                label: 'Keep Going!',
                onTap: () {
                  Navigator.pop(ctx);
                  _setMode(TimerMode.shortBreak);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  double get _progress =>
      _totalSeconds == 0 ? 0 : (_totalSeconds - _seconds) / _totalSeconds;

  Color get _modeColor {
    switch (_mode) {
      case TimerMode.focus:
        return AppColors.indigoPrimary;
      case TimerMode.shortBreak:
        return AppColors.mintGreen;
      case TimerMode.longBreak:
        return AppColors.cyanGlow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.deepNavy,
      body: SafeArea(
        child: Column(
          children: [
            // ── Header ──────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Focus Timer',
                    style: TextStyle(
                      
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w700,
                      fontSize: 20,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.cardSurface,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.bolt_rounded, color: AppColors.amberAccent, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          '$_sessionsCompleted sessions',
                          style: const TextStyle(
                            
                            color: AppColors.textPrimary,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ).animate().fadeIn(duration: 400.ms),
            ),
            // ── Mode Selector ────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: GlassCard(
                padding: const EdgeInsets.all(4),
                child: Row(
                  children: TimerMode.values.map((mode) {
                    final isSelected = _mode == mode;
                    return Expanded(
                      child: GestureDetector(
                        onTap: () => _setMode(mode),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            gradient: isSelected ? AppColors.primaryGradient : null,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Text(
                            _labels[mode]!,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              
                              color: isSelected ? Colors.white : AppColors.textMuted,
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ).animate(delay: 100.ms).fadeIn(),
            // ── Timer Ring ───────────────────────────────
            Expanded(
              child: Center(
                child: AnimatedBuilder(
                  animation: _pulseController,
                  builder: (_, __) {
                    return Stack(
                      alignment: Alignment.center,
                      children: [
                        // Glow bg
                        if (_running)
                          Container(
                            width: 280 + _pulseController.value * 20,
                            height: 280 + _pulseController.value * 20,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _modeColor.withOpacity(0.04 * _pulseController.value),
                            ),
                          ),
                        // Ring
                        SizedBox(
                          width: 260,
                          height: 260,
                          child: CustomPaint(
                            painter: _TimerRingPainter(
                              progress: _progress,
                              color: _modeColor,
                              backgroundColor: AppColors.cardSurface,
                            ),
                          ),
                        ),
                        // Time display
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              AppUtils.formatDuration(_seconds),
                              style: TextStyle(
                                
                                color: AppColors.textPrimary,
                                fontSize: 52,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -2,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              _labels[_mode]!,
                              style: TextStyle(
                                
                                color: _modeColor,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    );
                  },
                ),
              ),
            ).animate(delay: 200.ms).fadeIn().scale(begin: const Offset(0.9, 0.9)),
            // ── Subject Selector ─────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: GlassCard(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    const Icon(Icons.school_rounded, color: AppColors.textMuted, size: 18),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        style: const TextStyle(
                          
                          color: AppColors.textPrimary,
                          fontSize: 14,
                        ),
                        decoration: const InputDecoration(
                          hintText: 'What are you studying?',
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                          fillColor: Colors.transparent,
                          filled: false,
                        ),
                        onChanged: (v) => setState(() => _subject = v.isEmpty ? 'General' : v),
                      ),
                    ),
                  ],
                ),
              ),
            ).animate(delay: 250.ms).fadeIn(),
            // ── Controls ─────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 36),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Reset
                  GestureDetector(
                    onTap: _reset,
                    child: Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: AppColors.cardSurface,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withOpacity(0.06),
                        ),
                      ),
                      child: const Icon(Icons.replay_rounded, color: AppColors.textSecondary, size: 22),
                    ),
                  ),
                  const SizedBox(width: 24),
                  // Play/Pause
                  GestureDetector(
                    onTap: _toggle,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        gradient: _running
                            ? const LinearGradient(
                                colors: [AppColors.roseAccent, Color(0xFFFF6B6B)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              )
                            : AppColors.primaryGradient,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: (_running ? AppColors.roseAccent : AppColors.indigoPrimary)
                                .withOpacity(0.4),
                            blurRadius: 20,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Icon(
                        _running ? Icons.pause_rounded : Icons.play_arrow_rounded,
                        color: Colors.white,
                        size: 36,
                      ),
                    ),
                  ),
                  const SizedBox(width: 24),
                  // Skip
                  GestureDetector(
                    onTap: () {
                      if (_mode == TimerMode.focus) {
                        _setMode(TimerMode.shortBreak);
                      } else {
                        _setMode(TimerMode.focus);
                      }
                    },
                    child: Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: AppColors.cardSurface,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white.withOpacity(0.06)),
                      ),
                      child: const Icon(Icons.skip_next_rounded, color: AppColors.textSecondary, size: 22),
                    ),
                  ),
                ],
              ),
            ).animate(delay: 300.ms).fadeIn().slideY(begin: 0.1, end: 0),
          ],
        ),
      ),
    );
  }
}

class _TimerRingPainter extends CustomPainter {
  final double progress;
  final Color color;
  final Color backgroundColor;

  const _TimerRingPainter({
    required this.progress,
    required this.color,
    required this.backgroundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 12;
    const strokeWidth = 14.0;

    // Background ring
    final bgPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, bgPaint);

    // Progress ring
    final fgPaint = Paint()
      ..shader = LinearGradient(
        colors: [color, color.withOpacity(0.6)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2,
      2 * pi * progress,
      false,
      fgPaint,
    );
  }

  @override
  bool shouldRepaint(_TimerRingPainter old) =>
      old.progress != progress || old.color != color;
}
