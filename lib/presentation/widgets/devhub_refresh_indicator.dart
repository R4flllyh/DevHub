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
      duration: const Duration(milliseconds: 800),
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
      offsetToArmed: 45.0,
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
            final double value = controller.value.clamp(0.0, 1.0);

            return Stack(
              children: [
                // 1. Content Feed Displacement (Jarak geser sangat halus)
                Transform.translate(
                  offset: Offset(0.0, 30.0 * value),
                  child: child,
                ),

                // 2. Ultra-Thin Editorial Line (Menempel tepat di bawah AppBar)
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: controller.isLoading
                      ? _buildLoadingLine()
                      : _buildPullLine(value),
                ),
              ],
            );
          },
        );
      },
      child: widget.child,
    );
  }

  // Line mekar secara presisi sesuai rasio tarikan jari (0% -> 100%)
  Widget _buildPullLine(double value) {
    return Container(
      height: 1.5,
      alignment: Alignment.center,
      child: FractionallySizedBox(
        widthFactor: value, // Memanjang mulus dari tengah
        child: Container(color: const Color(0xFF1A1A1A)),
      ),
    );
  }

  // Line bernapas (pulsing) di atas feed saat sync data
  Widget _buildLoadingLine() {
    return Container(
      height: 1.5,
      alignment: Alignment.center,
      child: Container(
        width: double.infinity,
        color: const Color(
          0xFF1A1A1A,
        ).withOpacity(0.15 + (0.85 * _pulseController.value)),
      ),
    );
  }
}
