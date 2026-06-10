import 'package:flutter/material.dart';
import '../design/anchor_theme.dart';

class AnchorBackground extends StatelessWidget {
  final Widget child;

  const AnchorBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AnchorTheme.background,
      child: Stack(
        children: [
          // Background blobs
          Positioned(
            top: -100,
            left: -100,
            child: Container(
              width: 400,
              height: 400,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AnchorTheme.accent.withOpacity(0.05),
                    AnchorTheme.background.withOpacity(0),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -150,
            right: -50,
            child: Container(
              width: 500,
              height: 500,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AnchorTheme.accent.withOpacity(0.03),
                    AnchorTheme.background.withOpacity(0),
                  ],
                ),
              ),
            ),
          ),
          // Content
          SafeArea(child: child),
        ],
      ),
    );
  }
}
