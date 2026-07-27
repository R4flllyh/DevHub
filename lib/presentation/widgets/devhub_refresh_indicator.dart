import 'dart:math' as math;
import 'dart:ui';
import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';
import 'package:flutter/material.dart';

class DevHubRefreshIndicator extends StatefulWidget {
  final Widget child;
  final Future<void> Function() onRefresh;

  const DevHubRefreshIndicator({
    super.key,
    required this.child,
    required this.onRefresh,
  });

  @override
  State<DevHubRefreshIndicator> createState() => _DevHubRefreshIndicatorState();
}

class _DevHubRefreshIndicatorState extends State<DevHubRefreshIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _shimmerController;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomRefreshIndicator(
      onRefresh: widget.onRefresh,
      offsetToArmed: 48.0,
      onStateChanged: (change) {
        if (change.newState.isLoading) {
          _shimmerController.repeat();
        } else {
          _shimmerController.stop();
          _shimmerController.reset();
        }
      },
      builder: (context, child, controller) {
        return AnimatedBuilder(
          animation: Listenable.merge([controller, _shimmerController]),
          builder: (context, _) {
            final double value = controller.value.clamp(0.0, 1.0);
            final bool isArmed = controller.value >= 1.0;

            return Stack(
              children: [
                // 1. Content Translation
                Transform.translate(
                  offset: Offset(0.0, 38.0 * value),
                  child: child,
                ),

                // 2. Precision Pro Header
                if (value > 0.01)
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 38.0 * value,
                      alignment: Alignment.center,
                      child: CustomPaint(
                        size: const Size(36, 20),
                        painter: ProSyntaxPainter(
                          progress: value,
                          isArmed: isArmed,
                          isLoading: controller.isLoading,
                          shimmerValue: _shimmerController.value,
                        ),
                      ),
                    ),
                  ),
              ],
            );
          },
        );
      },
      child: widget.child,
    );
  }
}

/// CustomPainter Presisi untuk Visual < / > (Width Convergence + Slash Rotation)
class ProSyntaxPainter extends CustomPainter {
  final double progress;
  final bool isArmed;
  final bool isLoading;
  final double shimmerValue;

  ProSyntaxPainter({
    required this.progress,
    required this.isArmed,
    required this.isLoading,
    required this.shimmerValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Color activeColor = const Color(0xFF1A1A1A);
    final Color trackColor = const Color(0xFFE5E5E5);

    final Paint trackPaint = Paint()
      ..color = trackColor
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final Paint activePaint = Paint()
      ..color = activeColor
      ..strokeWidth = isArmed ? 2.2 : 2.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // 1. Kalkulasi Pergeseran Jarak < & > (Mendekat dari Lebar ke Presisi)
    // Saat progress 0.0, jarak offset 12px (lebar). Saat progress 1.0, offset 0px (merapat).
    final double spreadOffset = (1.0 - progress) * 12.0;

    // Path < (Digeser dari luar ke dalam)
    final Path leftBracket = Path()
      ..moveTo(size.width * 0.28 - spreadOffset, size.height * 0.20)
      ..lineTo(size.width * 0.08 - spreadOffset, size.height * 0.50)
      ..lineTo(size.width * 0.28 - spreadOffset, size.height * 0.80);

    // Path > (Digeser dari luar ke dalam)
    final Path rightBracket = Path()
      ..moveTo(size.width * 0.72 + spreadOffset, size.height * 0.20)
      ..lineTo(size.width * 0.92 + spreadOffset, size.height * 0.50)
      ..lineTo(size.width * 0.72 + spreadOffset, size.height * 0.80);

    // 2. Kalkulasi Rotasi Slash /
    // Rotasi dari 90 derajat (tidur/miring horizontal) menuju 0 derajat (kemiringan normal slash)
    final double centerPivotX = size.width * 0.50;
    final double centerPivotY = size.height * 0.50;
    final double rotationAngle = (1.0 - progress) * (math.pi / 2);

    final Path rawSlash = Path()
      ..moveTo(size.width * 0.58, size.height * 0.15)
      ..lineTo(size.width * 0.42, size.height * 0.85);

    // Transformasi Matriks Rotasi khusus untuk Slash di titik pusatnya
    final Matrix4 rotationMatrix = Matrix4.identity()
      ..translate(centerPivotX, centerPivotY)
      ..rotateZ(rotationAngle)
      ..translate(-centerPivotX, -centerPivotY);

    final Path rotatedSlash = rawSlash.transform(rotationMatrix.storage);

    final List<Path> paths = [leftBracket, rotatedSlash, rightBracket];

    // Gambar Base Track Abu-abu
    for (final path in paths) {
      canvas.drawPath(path, trackPaint);
    }

    // 3. Mode Syncing: Sweeping Shimmer Line sepanjang vektor
    if (isLoading) {
      for (final path in paths) {
        for (final metric in path.computeMetrics()) {
          final double head = metric.length * shimmerValue;
          final double tail = (head - (metric.length * 0.35)).clamp(
            0.0,
            metric.length,
          );
          final Path extractPath = metric.extractPath(tail, head);
          canvas.drawPath(extractPath, activePaint);
        }
      }
      return;
    }

    // 4. Mode Pulling: Sequential Precision Fill (0% -> 100%)
    if (progress <= 0.0) return;

    double totalLength = 0.0;
    final List<double> pathLengths = [];

    for (final path in paths) {
      double len = 0.0;
      for (final metric in path.computeMetrics()) {
        len += metric.length;
      }
      pathLengths.add(len);
      totalLength += len;
    }

    double currentDrawLength = totalLength * progress;

    for (int i = 0; i < paths.length; i++) {
      if (currentDrawLength <= 0) break;

      final path = paths[i];
      final pathLen = pathLengths[i];

      if (currentDrawLength >= pathLen) {
        canvas.drawPath(path, activePaint);
        currentDrawLength -= pathLen;
      } else {
        for (final metric in path.computeMetrics()) {
          final Path extractPath = metric.extractPath(0.0, currentDrawLength);
          canvas.drawPath(extractPath, activePaint);
        }
        currentDrawLength = 0;
      }
    }
  }

  @override
  bool shouldRepaint(covariant ProSyntaxPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.isArmed != isArmed ||
        oldDelegate.isLoading != isLoading ||
        oldDelegate.shimmerValue != shimmerValue;
  }
}
