import 'dart:ui';
import 'package:flutter/material.dart';

class GlassContainer extends StatelessWidget {
  final Widget child;
  final double blur;
  final double opacity;
  final BorderRadius borderRadius;
  final double borderWidth;
  final Color? borderColor;
  final Gradient? gradient;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? width;
  final double? height;

  const GlassContainer({
    super.key,
    required this.child,
    this.blur = 15.0,
    this.opacity = 0.1,
    this.borderRadius = const BorderRadius.all(Radius.circular(20)),
    this.borderWidth = 1.0,
    this.borderColor,
    this.gradient,
    this.padding = const EdgeInsets.all(16.0),
    this.margin,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // Choose sensible defaults if not specified
    final effectiveBorderColor = borderColor ?? 
        (isDark ? Colors.white.withOpacity(0.12) : Colors.white.withOpacity(0.35));
    
    final effectiveGradient = gradient ?? LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        (isDark ? Colors.white : Colors.white).withOpacity(opacity),
        (isDark ? Colors.black : Colors.white).withOpacity(opacity * 0.4),
      ],
    );

    return Container(
      width: width,
      height: height,
      margin: margin,
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: borderRadius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              borderRadius: borderRadius,
              border: Border.all(
                color: effectiveBorderColor,
                width: borderWidth,
              ),
              gradient: effectiveGradient,
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
