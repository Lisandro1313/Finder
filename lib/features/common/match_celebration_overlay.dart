import 'dart:math' as math;

import 'package:flutter/material.dart';

Future<void> showMatchCelebration(BuildContext context, String name) {
  return showGeneralDialog<void>(
    context: context,
    barrierLabel: 'match_celebration',
    barrierDismissible: false,
    barrierColor: Colors.black.withOpacity(0.22),
    transitionDuration: const Duration(milliseconds: 180),
    pageBuilder: (context, _, __) => _MatchCelebrationOverlay(name: name),
    transitionBuilder: (context, animation, _, child) {
      return FadeTransition(opacity: animation, child: child);
    },
  );
}

class _MatchCelebrationOverlay extends StatefulWidget {
  const _MatchCelebrationOverlay({required this.name});

  final String name;

  @override
  State<_MatchCelebrationOverlay> createState() => _MatchCelebrationOverlayState();
}

class _MatchCelebrationOverlayState extends State<_MatchCelebrationOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..forward();
    Future<void>.delayed(const Duration(milliseconds: 1350), () {
      if (!mounted) return;
      Navigator.of(context).pop();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Center(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              final t = Curves.easeOut.transform(_controller.value);
              return Stack(
                alignment: Alignment.center,
                children: [
                  ...List.generate(16, (index) {
                    final angle = (index / 16) * math.pi * 2;
                    final dist = 90 * t;
                    return Transform.translate(
                      offset: Offset(math.cos(angle) * dist, math.sin(angle) * dist),
                      child: Opacity(
                        opacity: (1 - t).clamp(0, 1),
                        child: Text(
                          index.isEven ? '❤' : '✨',
                          style: const TextStyle(fontSize: 22),
                        ),
                      ),
                    );
                  }),
                  Transform.scale(
                    scale: 0.85 + (0.25 * t),
                    child: Opacity(
                      opacity: (0.2 + 0.8 * t).clamp(0, 1),
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 28),
                        padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2C2640).withOpacity(0.94),
                          borderRadius: BorderRadius.circular(22),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text('🎉', style: TextStyle(fontSize: 34)),
                            const SizedBox(height: 8),
                            Text(
                              'MATCH CON ${widget.name.toUpperCase()}',
                              textAlign: TextAlign.center,
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.2,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Ahora escribile y arranca la conversacion.',
                              textAlign: TextAlign.center,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: Colors.white.withOpacity(0.88),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
