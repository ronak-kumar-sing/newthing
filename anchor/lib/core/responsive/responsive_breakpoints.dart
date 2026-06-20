import 'package:flutter/material.dart';

/// Centralized responsive breakpoints for Anchor.
/// All responsive decisions should go through these constants so mobile,
/// tablet, desktop, and wide-desktop layouts stay consistent.
class AnchorBreakpoints {
  AnchorBreakpoints._();

  static const double mobile = 0;
  static const double tablet = 600;
  static const double desktop = 900;
  static const double wideDesktop = 1200;
}

/// Convenience helpers for checking the current breakpoint from a [BuildContext].
bool isMobile(BuildContext context) {
  return MediaQuery.of(context).size.width < AnchorBreakpoints.tablet;
}

bool isTablet(BuildContext context) {
  final width = MediaQuery.of(context).size.width;
  return width >= AnchorBreakpoints.tablet && width < AnchorBreakpoints.desktop;
}

bool isDesktop(BuildContext context) {
  return MediaQuery.of(context).size.width >= AnchorBreakpoints.desktop;
}

bool isWideDesktop(BuildContext context) {
  return MediaQuery.of(context).size.width >= AnchorBreakpoints.wideDesktop;
}

/// A thin wrapper around [LayoutBuilder] that resolves to the correct builder
/// for the current breakpoint.
///
/// Mobile is returned for widths below [AnchorBreakpoints.tablet].
/// Tablet is returned for widths between tablet and desktop breakpoints.
/// Desktop is returned for widths at or above [AnchorBreakpoints.desktop].
class ResponsiveBuilder extends StatelessWidget {
  final WidgetBuilder mobile;
  final WidgetBuilder? tablet;
  final WidgetBuilder desktop;

  const ResponsiveBuilder({
    super.key,
    required this.mobile,
    this.tablet,
    required this.desktop,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= AnchorBreakpoints.desktop) {
          return desktop(context);
        }
        if (constraints.maxWidth >= AnchorBreakpoints.tablet) {
          return tablet?.call(context) ?? mobile(context);
        }
        return mobile(context);
      },
    );
  }
}

/// A value holder that resolves to a different value based on the current
/// breakpoint. Useful for small tweaks like padding or column counts.
class ResponsiveValue<T> {
  final T mobile;
  final T? tablet;
  final T desktop;

  const ResponsiveValue({
    required this.mobile,
    this.tablet,
    required this.desktop,
  });

  T resolve(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width >= AnchorBreakpoints.desktop) return desktop;
    if (width >= AnchorBreakpoints.tablet) return tablet ?? mobile;
    return mobile;
  }

  T resolveFromConstraints(BoxConstraints constraints) {
    if (constraints.maxWidth >= AnchorBreakpoints.desktop) return desktop;
    if (constraints.maxWidth >= AnchorBreakpoints.tablet) return tablet ?? mobile;
    return mobile;
  }
}
