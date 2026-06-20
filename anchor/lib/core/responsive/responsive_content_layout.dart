import 'package:flutter/material.dart';
import '../theme/slice_spacing.dart';
import 'desktop_scaffold.dart';
import 'responsive_breakpoints.dart';

/// Switches between a mobile body and a desktop body based on the current
/// breakpoint. This is the simplest way to make a screen responsive while
/// keeping the mobile implementation untouched.
class ResponsiveContentLayout extends StatelessWidget {
  final Widget mobileBody;
  final Widget desktopBody;
  final double maxContentWidth;
  final double desktopPadding;

  const ResponsiveContentLayout({
    super.key,
    required this.mobileBody,
    required this.desktopBody,
    this.maxContentWidth = SliceSpacing.maxContentWidth,
    this.desktopPadding = SliceSpacing.desktopPadding,
  });

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      mobile: (_) => mobileBody,
      tablet: (_) => mobileBody,
      desktop: (_) => DesktopScaffold(
        maxContentWidth: maxContentWidth,
        horizontalPadding: desktopPadding,
        body: desktopBody,
      ),
    );
  }
}

/// A reusable grid for desktop card layouts.
/// Automatically picks 2 columns at desktop width and 3 columns at wide desktop.
class DesktopCardGrid extends StatelessWidget {
  final List<Widget> children;
  final int crossAxisCount;
  final double spacing;
  final double runSpacing;
  final EdgeInsetsGeometry padding;
  final double? childAspectRatio;

  const DesktopCardGrid({
    super.key,
    required this.children,
    this.crossAxisCount = 2,
    this.spacing = SliceSpacing.lg,
    this.runSpacing = SliceSpacing.lg,
    this.padding = EdgeInsets.zero,
    this.childAspectRatio,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final columns = width >= AnchorBreakpoints.wideDesktop ? 3 : crossAxisCount;

    return GridView.count(
      crossAxisCount: columns,
      crossAxisSpacing: spacing,
      mainAxisSpacing: runSpacing,
      padding: padding,
      childAspectRatio: childAspectRatio ?? _defaultAspectRatio(columns),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: children,
    );
  }

  double _defaultAspectRatio(int columns) {
    // Taller cards when there are fewer columns so content has room to breathe.
    return columns <= 2 ? 1.15 : 1.35;
  }
}

/// A two-column desktop layout with a wider main area and a narrower side area.
class DesktopTwoColumnLayout extends StatelessWidget {
  final Widget left;
  final Widget right;
  final double leftFlex;
  final double rightFlex;
  final double spacing;

  const DesktopTwoColumnLayout({
    super.key,
    required this.left,
    required this.right,
    this.leftFlex = 3,
    this.rightFlex = 2,
    this.spacing = SliceSpacing.lg,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(flex: leftFlex.toInt(), child: left),
        SizedBox(width: spacing),
        Expanded(flex: rightFlex.toInt(), child: right),
      ],
    );
  }
}
