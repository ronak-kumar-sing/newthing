import 'package:flutter/material.dart';
import '../design/anchor_theme.dart';
import '../theme/slice_spacing.dart';
import '../widgets/anchor_background.dart';

/// A scaffold tuned for desktop/web wide screens.
/// Centers content with a max width, applies consistent desktop padding,
/// and keeps the Anchor dark background.
class DesktopScaffold extends StatelessWidget {
  final Widget body;
  final PreferredSizeWidget? appBar;
  final double maxContentWidth;
  final double horizontalPadding;
  final bool useBackground;

  const DesktopScaffold({
    super.key,
    required this.body,
    this.appBar,
    this.maxContentWidth = SliceSpacing.maxContentWidth,
    this.horizontalPadding = SliceSpacing.desktopPadding,
    this.useBackground = true,
  });

  @override
  Widget build(BuildContext context) {
    final content = Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxContentWidth),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
          child: body,
        ),
      ),
    );

    return Scaffold(
      backgroundColor: AnchorTheme.background,
      appBar: appBar,
      body: useBackground ? AnchorBackground(child: content) : content,
    );
  }
}

/// A full-width section that centers its child up to the desktop max content
/// width. Useful when a screen wants to break out of a grid but still stay
/// within the readable area.
class DesktopMaxWidth extends StatelessWidget {
  final Widget child;
  final double maxContentWidth;
  final double horizontalPadding;

  const DesktopMaxWidth({
    super.key,
    required this.child,
    this.maxContentWidth = SliceSpacing.maxContentWidth,
    this.horizontalPadding = SliceSpacing.desktopPadding,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxContentWidth),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
          child: child,
        ),
      ),
    );
  }
}
