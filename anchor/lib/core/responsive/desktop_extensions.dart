import 'package:flutter/material.dart';
import '../theme/slice_spacing.dart';
import 'responsive_breakpoints.dart';

/// Convenience extensions on [BuildContext] and [BoxConstraints] for quick
/// responsive checks without repeating MediaQuery boilerplate.
extension BuildContextResponsive on BuildContext {
  double get screenWidth => MediaQuery.of(this).size.width;

  bool get isMobile => screenWidth < AnchorBreakpoints.tablet;
  bool get isTablet =>
      screenWidth >= AnchorBreakpoints.tablet &&
      screenWidth < AnchorBreakpoints.desktop;
  bool get isDesktop => screenWidth >= AnchorBreakpoints.desktop;
  bool get isWideDesktop => screenWidth >= AnchorBreakpoints.wideDesktop;

  /// A convenient max width for centered desktop content; infinity on mobile
  /// so the widget fills the available width.
  double get contentMaxWidth =>
      isDesktop ? SliceSpacing.maxContentWidth : double.infinity;
}

extension BoxConstraintsResponsive on BoxConstraints {
  bool get isMobile => maxWidth < AnchorBreakpoints.tablet;
  bool get isTablet =>
      maxWidth >= AnchorBreakpoints.tablet &&
      maxWidth < AnchorBreakpoints.desktop;
  bool get isDesktop => maxWidth >= AnchorBreakpoints.desktop;
  bool get isWideDesktop => maxWidth >= AnchorBreakpoints.wideDesktop;
}
