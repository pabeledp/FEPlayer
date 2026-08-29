import 'dart:ui';
import 'package:flutter/material.dart';

class GlassCard extends StatelessWidget {
  final Widget child;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final BorderRadius? borderRadius;
  final Color? color;
  final Color? borderColor;
  final double borderWidth;
  final double blurSigma;
  final List<BoxShadow>? shadows;
  final VoidCallback? onTap;

  const GlassCard({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.padding,
    this.margin,
    this.borderRadius,
    this.color,
    this.borderColor,
    this.borderWidth = 1.0,
    this.blurSigma = 18.0,
    this.shadows,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? BorderRadius.circular(20);

    Widget content = Container(
      width: width,
      height: height,
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color ?? Colors.white.withOpacity(0.92),
        borderRadius: radius,
        border: Border.all(
          color: borderColor ?? const Color(0xFFE2E8F0),
          width: borderWidth,
        ),
        boxShadow: shadows ?? [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 18,
            offset: const Offset(0, 6),
            spreadRadius: 0,
          ),
        ],
      ),
      child: child,
    );

    Widget blurred = ClipRRect(
      borderRadius: radius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
        child: content,
      ),
    );

    if (margin != null) {
      blurred = Padding(padding: margin!, child: blurred);
    }

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: blurred,
        ),
      );
    }

    return blurred;
  }
}
