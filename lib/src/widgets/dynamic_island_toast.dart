import 'package:flutter/material.dart';
import '../constants/app_theme.dart';
import 'glass_card.dart';

class DynamicIslandToast extends StatelessWidget {
  final String message;
  final bool isVisible;

  const DynamicIslandToast({
    super.key,
    required this.message,
    required this.isVisible,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOutBack,
      top: isVisible ? 16 : -80,
      left: 0,
      right: 0,
      child: Center(
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 300),
          opacity: isVisible ? 1.0 : 0.0,
          child: GlassCard(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            borderRadius: BorderRadius.circular(30),
            color: const Color(0xE60F172A), // Apple dark glass capsule
            borderColor: AppTheme.neonCyan.withOpacity(0.4),
            borderWidth: 1.2,
            shadows: [
              BoxShadow(
                color: AppTheme.neonCyan.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
              BoxShadow(
                color: Colors.black.withOpacity(0.4),
                blurRadius: 16,
              ),
            ],
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 26,
                  height: 26,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: AppTheme.accentGradient,
                    boxShadow: AppTheme.cyanGlow,
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.check_rounded,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  message,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
