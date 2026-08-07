import 'dart:ui';
import 'package:flutter/material.dart';

/// Teal gradient background container — used as the Scaffold body background.
class GlassBackground extends StatelessWidget {
  const GlassBackground({super.key, required this.child});

  final Widget child;

  static const Color _colorA = Color(0xFF00897B);
  static const Color _colorB = Color(0xFF004D40);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_colorA, _colorB],
        ),
      ),
      child: child,
    );
  }
}

/// Frosted glass card — BackdropFilter blur + semi-transparent white overlay.
class GlassCard extends StatelessWidget {
  const GlassCard({
    super.key,
    required this.child,
    this.borderRadius = 20,
    this.padding,
    this.hasError = false,
    this.blurSigma = 10.0,
    this.opacity = 0.15,
    this.borderOpacity = 0.2,
    this.shadowColor = const Color(0xFF00695C),
    this.shadowOpacity = 0.3,
  });

  final Widget child;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;
  final bool hasError;
  final double blurSigma;
  final double opacity;
  final double borderOpacity;
  final Color shadowColor;
  final double shadowOpacity;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          BoxShadow(
            color: shadowColor.withValues(alpha: shadowOpacity),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: hasError ? 0.05 : opacity),
              borderRadius: BorderRadius.circular(borderRadius),
              border: Border.all(
                color: hasError
                    ? Colors.red.withValues(alpha: borderOpacity)
                    : Colors.white.withValues(alpha: borderOpacity),
                width: hasError ? 2 : 1,
              ),
            ),
            padding: padding,
            child: child,
          ),
        ),
      ),
    );
  }
}

/// Gradient teal button with subtle glow shadow.
class GlassButton extends StatelessWidget {
  const GlassButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.icon,
    this.filled = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    final widget = filled ? _gradientButton : _outlinedButton;

    return widget;
  }

  Widget get _gradientButton {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00897B).withValues(alpha: 0.5),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF00897B),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: 0,
        ),
        child: _content(Colors.white),
      ),
    );
  }

  Widget get _outlinedButton {
    return OutlinedButton(
      onPressed: isLoading ? null : onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.white,
        side: BorderSide(color: Colors.white.withValues(alpha: 0.6)),
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      child: _content(Colors.white),
    );
  }

  Widget _content(Color color) {
    if (isLoading) {
      return SizedBox(
        height: 20,
        width: 20,
        child: CircularProgressIndicator(color: color, strokeWidth: 2),
      );
    }
    if (icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [Icon(icon, size: 20), const SizedBox(width: 8), Text(label)],
      );
    }
    return Text(label);
  }
}

/// Glassmorphic pill slider used across all assessment screens.
/// - Frosted glass pill track
/// - Glowing white thumb with teal shadow
/// - Glass value badge above the thumb
/// - Unanswered state: red-tinted glass track
class GlassLabeledSlider extends StatelessWidget {
  const GlassLabeledSlider({
    super.key,
    required this.title,
    required this.value,
    required this.min,
    required this.max,
    required this.showError,
    required this.currentLabel,
    required this.minLabel,
    required this.maxLabel,
    required this.onChanged,
    this.isRequired = false,
    this.errorMessage = 'This question is required',
  });

  final String title;
  final int value;
  final int min;
  final int max;
  final bool showError;
  final String currentLabel;
  final String minLabel;
  final String maxLabel;
  final ValueChanged<int> onChanged;
  final bool isRequired;
  final String errorMessage;

  int get _divisions => max - min;

  bool get _unanswered => value == -1 || value == 0;

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text.rich(
            TextSpan(
              text: title,
              children: [
                if (isRequired)
                  const TextSpan(
                    text: ' *',
                    style: TextStyle(color: Colors.redAccent),
                  ),
              ],
            ),
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: GlassCard(
              hasError: showError && _unanswered,
              padding: const EdgeInsets.all(20),
              borderRadius: 20,
              opacity: 0.12,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildValueBadge(context),
                  const SizedBox(height: 12),
                  _buildSlider(context),
                  const SizedBox(height: 8),
                  _buildMinMaxLabels(context),
                ],
              ),
            ),
          ),
          if (showError && _unanswered)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Text(
                errorMessage,
                style: const TextStyle(color: Colors.redAccent, fontSize: 12),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildValueBadge(BuildContext context) {
    final displayText = currentLabel.isEmpty ? '--' : currentLabel;
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withValues(alpha: 0.3), width: 1),
          ),
          child: Text(
            displayText,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  Widget _buildSlider(BuildContext context) {
    final displayValue = value == -1 || value == 0
        ? min.toDouble()
        : value.toDouble();

    return SliderTheme(
      data: SliderTheme.of(context).copyWith(
        trackHeight: 8,
        activeTrackColor: const Color(0xFF4DB6AC),
        inactiveTrackColor: Colors.white.withValues(alpha: 0.2),
        thumbColor: Colors.white,
        overlayColor: const Color(0xFF00897B).withValues(alpha: 0.2),
        thumbShape: GlowingThumbShape(),
        trackShape: _GlassTrackShape(showError: showError && _unanswered),
        overlayShape: const RoundSliderOverlayShape(overlayRadius: 24),
      ),
      child: Slider(
        min: min.toDouble(),
        max: max.toDouble(),
        divisions: _divisions == 0 ? 1 : _divisions,
        value: displayValue,
        onChanged: (v) => onChanged(v.round()),
      ),
    );
  }

  Widget _buildMinMaxLabels(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Text(
              minLabel,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: Colors.white70),
              textAlign: TextAlign.left,
            ),
          ),
          Flexible(
            child: Text(
              maxLabel,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: Colors.white70),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}

/// Glowing white thumb with teal glow shadow.
class GlowingThumbShape extends SliderComponentShape {
  GlowingThumbShape();

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) {
    return const Size(24, 24);
  }

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    required bool isDiscrete,
    required TextPainter labelPainter,
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required TextDirection textDirection,
    required double value,
    required double textScaleFactor,
    required Size sizeWithOverflow,
  }) {
    final canvas = context.canvas;

    // Outer teal glow
    final glowPaint = Paint()
      ..color = const Color(0xFF00897B).withValues(alpha: 0.45)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
    canvas.drawCircle(center, 14, glowPaint);

    // Inner glow
    final innerGlowPaint = Paint()
      ..color = const Color(0xFF4DB6AC).withValues(alpha: 0.4)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
    canvas.drawCircle(center, 10, innerGlowPaint);

    // White circle
    final whitePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, 12, whitePaint);
  }
}

/// Glass pill track — frosted white for answered, tinted red for unanswered.
class _GlassTrackShape extends SliderTrackShape {
  const _GlassTrackShape({required this.showError});

  final bool showError;

  @override
  Rect getPreferredRect({
    required RenderBox parentBox,
    Offset offset = Offset.zero,
    required SliderThemeData sliderTheme,
    bool isEnabled = false,
    bool isDiscrete = false,
  }) {
    final trackHeight = sliderTheme.trackHeight ?? 8;
    final trackLeft = offset.dx;
    final trackTop = offset.dy + (parentBox.size.height - trackHeight) / 2;
    final trackWidth = parentBox.size.width;
    return Rect.fromLTWH(trackLeft, trackTop, trackWidth, trackHeight);
  }

  @override
  void paint(
    PaintingContext context,
    Offset offset, {
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required Animation<double> enableAnimation,
    required Offset thumbCenter,
    Offset? secondaryOffset,
    bool isEnabled = false,
    bool isDiscrete = false,
    required TextDirection textDirection,
  }) {
    final canvas = context.canvas;
    final trackRect = getPreferredRect(
      parentBox: parentBox,
      offset: offset,
      sliderTheme: sliderTheme,
    );

    final trackRadius = Radius.circular(trackRect.height / 2);

    // Inactive track — frosted glass pill
    _drawGlassPill(
      canvas,
      trackRect,
      trackRadius,
      showError ? Colors.red.withValues(alpha: 0.35) : Colors.white.withValues(alpha: 0.2),
      showError ? Colors.red.withValues(alpha: 0.15) : Colors.white.withValues(alpha: 0.08),
    );

    // Active track — teal gradient (or red if error)
    final activeRect = Rect.fromLTRB(
      trackRect.left,
      trackRect.top,
      thumbCenter.dx,
      trackRect.bottom,
    );
    if (activeRect.width > 0) {
      final activePaint = Paint()
        ..shader = LinearGradient(
          colors: showError
              ? [const Color(0xFFFF6B6B), const Color(0xFFFF1744)]
              : [const Color(0xFF4DB6AC), const Color(0xFF00897B)],
        ).createShader(activeRect);

      final activeRRect = RRect.fromRectAndRadius(activeRect, trackRadius);
      canvas.drawRRect(activeRRect, activePaint);
    }

    // Track border
    final borderPaint = Paint()
      ..color = showError
          ? Colors.red.withValues(alpha: 0.4)
          : Colors.white.withValues(alpha: 0.25)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    final fullRRect = RRect.fromRectAndRadius(trackRect, trackRadius);
    canvas.drawRRect(fullRRect, borderPaint);
  }

  void _drawGlassPill(
    Canvas canvas,
    Rect rect,
    Radius radius,
    Color fillColor,
    Color overlayColor,
  ) {
    final fillRRect = RRect.fromRectAndRadius(rect, radius);
    canvas.drawRRect(fillRRect, Paint()..color = fillColor);

    // Subtle inner highlight
    final innerRect = rect.deflate(1);
    final innerRadius = Radius.circular((rect.height - 2) / 2);
    final innerHighlight = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Colors.white.withValues(alpha: 0.2), Colors.transparent],
      ).createShader(innerRect);
    canvas.drawRRect(
      RRect.fromRectAndRadius(innerRect, innerRadius),
      innerHighlight,
    );
  }
}
