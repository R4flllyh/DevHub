import 'dart:math' as math;
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
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomRefreshIndicator(
      onRefresh: widget.onRefresh,
      offsetToArmed: 50.0,
      onStateChanged: (change) {
        if (change.newState.isLoading) {
          _pulseController.repeat(reverse: true);
        } else {
          _pulseController.stop();
          _pulseController.reset();
        }
      },
      builder: (context, child, controller) {
        return AnimatedBuilder(
          animation: Listenable.merge([controller, _pulseController]),
          builder: (context, _) {
            final double value = controller.value.clamp(0.0, 1.2);
            final bool isArmed = controller.value >= 1.0;

            return Stack(
              children: [
                // 1. Smooth Feed Displacement
                Transform.translate(
                  offset: Offset(0.0, 38.0 * value),
                  child: child,
                ),

                // 2. Syntax Developer Header
                if (value > 0.01)
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 38.0 * value,
                      alignment: Alignment.center,
                      child: controller.isLoading
                          ? _buildTerminalCursorPulse()
                          : _buildSyntaxPull(value, isArmed),
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

  // Visual Syntax saat Ditarik: < / > Meregang & Mengunci
  Widget _buildSyntaxPull(double value, bool isArmed) {
    final double gap = (16.0 * value).clamp(2.0, 16.0);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "<",
          style: TextStyle(
            fontSize: 14,
            fontFamily: 'monospace',
            fontWeight: FontWeight.w700,
            color: isArmed ? const Color(0xFF1A1A1A) : Colors.grey[400],
          ),
        ),
        SizedBox(width: isArmed ? 2.0 : gap / 2),
        Transform.rotate(
          angle: (1.0 - value) * math.pi * 0.5,
          child: Text(
            "/",
            style: TextStyle(
              fontSize: 14,
              fontFamily: 'monospace',
              fontWeight: FontWeight.w700,
              color: isArmed ? const Color(0xFF1A1A1A) : Colors.grey[400],
            ),
          ),
        ),
        SizedBox(width: isArmed ? 2.0 : gap / 2),
        Text(
          ">",
          style: TextStyle(
            fontSize: 14,
            fontFamily: 'monospace',
            fontWeight: FontWeight.w700,
            color: isArmed ? const Color(0xFF1A1A1A) : Colors.grey[400],
          ),
        ),
      ],
    );
  }

  // Visual Terminal Cursor saat Syncing (Monochrome Line Pulse)
  Widget _buildTerminalCursorPulse() {
    return Container(
      width: 18.0,
      height: 2.0,
      decoration: BoxDecoration(
        color: const Color(
          0xFF1A1A1A,
        ).withOpacity(0.2 + (0.8 * _pulseController.value)),
        borderRadius: BorderRadius.circular(1.0),
      ),
    );
  }
}
