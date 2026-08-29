import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_theme.dart';
import '../controllers/library_controller.dart';
import 'glass_card.dart';

class PermissionGuardView extends StatelessWidget {
  const PermissionGuardView({super.key});

  @override
  Widget build(BuildContext context) {
    final library = context.watch<LibraryController>();

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
        child: GlassCard(
          padding: const EdgeInsets.all(28),
          borderRadius: BorderRadius.circular(24),
          color: Colors.white.withOpacity(0.95),
          borderColor: const Color(0xFFE2E8F0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon with Gradient Aura
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: AppTheme.accentGradient,
                  boxShadow: AppTheme.buttonGlow,
                ),
                child: const Center(
                  child: Icon(
                    Icons.lock_open_rounded,
                    color: Colors.white,
                    size: 34,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Title
              const Text(
                "Media Storage Access Required",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF0F172A),
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 8),

              // Explanation
              const Text(
                "FE Player needs permission to index and play your local videos, movies, and music stored on this device.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF475569),
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 24),

              // Action CTA
              GestureDetector(
                onTap: () {
                  if (library.isPermanentlyDenied) {
                    library.openSystemSettings();
                  } else {
                    library.checkAndRequestPermissions().then((granted) {
                      if (granted) {
                        library.scanDeviceVideos();
                      }
                    });
                  }
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    gradient: AppTheme.accentGradient,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: AppTheme.buttonGlow,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        library.isPermanentlyDenied
                            ? Icons.settings_rounded
                            : Icons.check_circle_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        library.isPermanentlyDenied
                            ? "Open System Settings"
                            : "Grant Storage Permission",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
