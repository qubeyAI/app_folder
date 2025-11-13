import 'package:flutter/material.dart';

class GlowingPathAnimator extends StatefulWidget {
  final Offset start;
  final Offset end;
  final VoidCallback onFinish;

  const GlowingPathAnimator({
    Key? key,
    required this.start,
    required this.end,
    required this.onFinish,
  }) : super(key: key);

  @override
  State<GlowingPathAnimator> createState() => _GlowingPathAnimatorState();
}

class _GlowingPathAnimatorState extends State<GlowingPathAnimator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
    _controller.forward().whenComplete(widget.onFinish);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        final dx = widget.start.dx +
            (widget.end.dx - widget.start.dx) * _animation.value;
        final dy = widget.start.dy +
            (widget.end.dy - widget.start.dy) * _animation.value;

        return Stack(
          children: [
            // 🌟 Glow trail effect (a fading gradient line)
            CustomPaint(
              painter: _GlowLinePainter(
                start: widget.start,
                end: Offset(dx, dy),
                progress: _animation.value,
              ),
            ),

            // 🟢 Glowing pulse moving on the line
            Positioned(
              left: dx - 8,
              top: dy - 8,
              child: Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.tealAccent.withOpacity(0.8),
                      blurRadius: 20,
                      spreadRadius: 6,
                    ),
                  ],
                  gradient: const LinearGradient(
                    colors: [Colors.tealAccent, Colors.greenAccent],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _GlowLinePainter extends CustomPainter {
  final Offset start;
  final Offset end;
  final double progress;

  _GlowLinePainter({
    required this.start,
    required this.end,
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = LinearGradient(
        colors: [
          Colors.tealAccent.withOpacity(0.1),
          Colors.tealAccent.withOpacity(0.8),
          Colors.tealAccent.withOpacity(0.1),
        ],
      ).createShader(Rect.fromPoints(start, end))
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 5
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);

    final path = Path()
      ..moveTo(start.dx, start.dy)
      ..lineTo(
        start.dx + (end.dx - start.dx) * progress,
        start.dy + (end.dy - start.dy) * progress,
      );

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _GlowLinePainter oldDelegate) =>
      oldDelegate.progress != progress;
}