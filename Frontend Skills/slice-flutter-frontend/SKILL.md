---
name: slice-flutter-frontend
description: Slice-inspired Flutter frontend design system with bold typography, glossy glassmorphism cards, dark-first aesthetic, transparent UI layers, specular highlights, and smooth scroll animations. Use when building Flutter apps requiring premium dark-mode UI with glossy surfaces, translucent cards, hero sections, frosted glass effects, animated charts, responsive desktop+mobile layouts, and premium micro-interactions. NOT for banking - adapt visual patterns for general consumer apps.
---

# Slice-Inspired Flutter Frontend Skill

## Overview

Build premium Flutter applications with bold visual design inspired by [slice.bank.in](https://slice.bank.in/) -- reimagined in a **dark-first, glossy aesthetic**. Features large expressive typography, glassmorphism with specular highlights, translucent layered UI, 3D decorative elements, and fluid animations. Works for both desktop (web) and mobile from a single Flutter codebase.

**Dark mode is the default and primary theme.** All components are designed for dark backgrounds with glossy, light-transmitting surfaces. Light mode support is secondary.

**Important**: This is NOT a banking application. Adapt Slice's visual patterns (typography, colors, animations, layout) for your non-banking use case. Reference slice.bank.in for aesthetic inspiration only.

## Design System

### Color Palette (Dark-First)

Dark mode is the default. All surfaces are designed to float on deep dark backgrounds with glossy translucent overlays.

```dart
class SliceColors {
  // Primary brand
  static const Color primaryMagenta = Color(0xFFCC00CC);
  static const Color primaryPurple = Color(0xFF7C3AED);
  static const Color primaryLime = Color(0xFFCCFF00);
  static const Color primaryCyan = Color(0xFF00D4FF);
  
  // Dark backgrounds (primary theme)
  static const Color bgDark = Color(0xFF0A0A0F);
  static const Color bgDarkElevated = Color(0xFF12121A);
  static const Color bgDarkSurface = Color(0xFF1A1A26);
  static const Color bgDarkCard = Color(0xFF222233);
  
  // Light backgrounds (secondary)
  static const Color bgLight = Color(0xFFF8F9FA);
  static const Color bgLightSurface = Color(0xFFFFFFFF);
  
  // Gradient presets (dark theme -- glossy, vibrant)
  static const Gradient heroGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF7C3AED), Color(0xFFCC00CC), Color(0xFF0A0A0F)],
  );
  
  static const Gradient creditGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF4C1D95), Color(0xFF7C3AED), Color(0xFF0A0A0F)],
  );
  
  static const Gradient glowGradient = RadialGradient(
    center: Alignment.topCenter,
    radius: 0.8,
    colors: [Color(0x307C3AED), Color(0x000A0A0F)],
  );
  
  // Glossy surface fills (dark theme)
  static const Color glassDark = Color(0x18FFFFFF);
  static const Color glassDarkBorder = Color(0x20FFFFFF);
  static const Color glassLight = Color(0x40FFFFFF);
  static const Color glassBorder = Color(0x30FFFFFF);
  static const Color glassHighlight = Color(0x60FFFFFF); // Specular sheen
  
  // Text (dark theme)
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFA0A0B8);
  static const Color textMuted = Color(0xFF6B6B80);
  static const Color textOnDark = Color(0xFFFFFFFF);
  static const Color textOnLight = Color(0xFF1A1A2E);
  
  // Semantic
  static const Color success = Color(0xFF22C55E);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  
  // Glossy effects
  static const Color sheenTop = Color(0x50FFFFFF);
  static const Color sheenBottom = Color(0x08FFFFFF);
  static const Color reflection = Color(0x15FFFFFF);
  static const Color edgeGlow = Color(0x40CC00CC);
}
```

### Typography

Slice uses bold, oversized headings with tight letter-spacing. Scale for Flutter:

```dart
class SliceTypography {
  static const String fontFamily = 'Inter'; // or Geist/Satoshi
  
  // Hero headlines - massive, bold (dark theme default)
  static const TextStyle hero = TextStyle(
    fontSize: 56,
    fontWeight: FontWeight.w800,
    letterSpacing: -2.0,
    height: 1.05,
    color: SliceColors.textPrimary, // White on dark
  );
  
  // Section headlines
  static const TextStyle h1 = TextStyle(
    fontSize: 40,
    fontWeight: FontWeight.w700,
    letterSpacing: -1.5,
    height: 1.1,
  );
  
  static const TextStyle h2 = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    letterSpacing: -1.0,
    height: 1.2,
  );
  
  static const TextStyle h3 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.5,
    height: 1.3,
  );
  
  // Body
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    height: 1.6,
  );
  
  static const TextStyle body = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.5,
  );
  
  // Labels/captions
  static const TextStyle caption = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
  );
  
  // Amount/balance displays (mobile app style)
  static const TextStyle amount = TextStyle(
    fontSize: 48,
    fontWeight: FontWeight.w700,
    letterSpacing: -1.0,
  );
  
  // Tab labels
  static const TextStyle tabLabel = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
  );
}
```

### Spacing & Layout

```dart
class SliceSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 48;
  static const double xxxl = 64;
  
  // Border radius (Slice uses generous rounding)
  static const double radiusSm = 8;
  static const double radiusMd = 16;
  static const double radiusLg = 24;
  static const double radiusXl = 32;
  static const double radiusFull = 999;
  
  // Content max width for desktop
  static const double maxContentWidth = 1200;
  
  // Page horizontal padding (desktop)
  static const double desktopPadding = 48;
  static const double mobilePadding = 16;
}
```

## Core Visual Patterns

### 1. Hero Section (Full-Bleed with Overlay Text)

Slice's signature pattern: full-width artistic background image with large centered text overlay.

**For Desktop:**
```dart
Widget heroSection({
  required String headline,
  required String subtitle,
  required String backgroundImage,
  required VoidCallback onCtaPressed,
}) {
  return ClipRRect(
    borderRadius: BorderRadius.circular(SliceSpacing.radiusXl),
    child: Container(
      height: 600,
      margin: EdgeInsets.all(SliceSpacing.md),
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(backgroundImage),
          fit: BoxFit.cover,
          // Dark overlay on images for dark theme consistency
          colorFilter: ColorFilter.mode(
            SliceColors.bgDark.withOpacity(0.5),
            BlendMode.darken,
          ),
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [
              SliceColors.bgDark.withOpacity(0.95),
              SliceColors.bgDark.withOpacity(0.3),
              Colors.transparent,
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(headline, style: SliceTypography.hero.copyWith(
                color: SliceColors.textPrimary, // White on dark
                fontSize: 72,
              )),
              SizedBox(height: SliceSpacing.md),
              Text(subtitle, style: SliceTypography.bodyLarge.copyWith(
                color: SliceColors.textSecondary,
              )),
              SizedBox(height: SliceSpacing.xl),
              glossyButton('Get Started', onCtaPressed),
            ],
          ),
        ),
      ),
    ),
  );
}
```

**For Mobile:** Stack layout with text below image instead of overlay, or smaller hero height (350-400).

### 2. Glassmorphism Cards (Frosted Glass)

Used extensively for feature cards, info panels, and overlays:

```dart
Widget glassCard({
  required Widget child,
  double? width,
  double? height,
  EdgeInsets? padding,
}) {
  return ClipRRect(
    borderRadius: BorderRadius.circular(SliceSpacing.radiusLg),
    child: BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
      child: Container(
        width: width,
        height: height,
        padding: padding ?? EdgeInsets.all(SliceSpacing.lg),
        decoration: BoxDecoration(
          color: SliceColors.glassWhite,
          borderRadius: BorderRadius.circular(SliceSpacing.radiusLg),
          border: Border.all(color: SliceColors.glassBorder, width: 1),
        ),
        child: child,
      ),
    ),
  );
}
```

### 3. Pill Buttons

Slice's signature CTA style - fully rounded with gradient fills:

```dart
Widget pillButton(String text, VoidCallback onPressed, {bool isPrimary = true}) {
  return GestureDetector(
    onTap: onPressed,
    child: Container(
      padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
      decoration: BoxDecoration(
        gradient: isPrimary ? LinearGradient(
          colors: [SliceColors.primaryMagenta, SliceColors.primaryPurple],
        ) : null,
        color: isPrimary ? null : Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(SliceSpacing.radiusFull),
        border: isPrimary ? null : Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: Text(text, style: SliceTypography.body.copyWith(
        color: Colors.white,
        fontWeight: FontWeight.w600,
      )),
    ),
  );
}
```

### 4. Feature Showcase with Tabs

Bottom-aligned tab bar switching between feature demos:

```dart
// Use DefaultTabController + TabBar at bottom of section
Widget featureShowcase({
  required List<String> tabLabels,
  required List<Widget> tabContents,
  required String backgroundImage,
}) {
  return Container(
    height: 700,
    decoration: BoxDecoration(
      image: DecorationImage(
        image: AssetImage(backgroundImage),
        fit: BoxFit.cover,
        colorFilter: ColorFilter.mode(
          SliceColors.bgDark.withOpacity(0.6),
          BlendMode.darken,
        ),
      ),
    ),
    child: Column(
      children: [
        Expanded(child: TabBarView(children: tabContents)),
        Container(
          padding: EdgeInsets.symmetric(horizontal: SliceSpacing.lg, vertical: SliceSpacing.md),
          child: glassNavBar(
            currentIndex: 0,
            onTap: (_) {},
            items: tabLabels.map((l) => NavItem(icon: Icons.circle, label: l)).toList(),
          ),
        ),
      ],
    ),
  );
}
```

### 5. Gradient Background Sections

Per-page unique gradient themes (adapt colors to your brand):

```dart
Widget gradientSection({
  required Gradient gradient,
  required Widget child,
  double height = 800,
}) {
  return Container(
    height: height,
    decoration: BoxDecoration(
      gradient: gradient,
      // Subtle noise texture overlay for depth
      backgroundBlendMode: BlendMode.srcOver,
    ),
    child: Stack(
      children: [
        // Ambient glow orbs for depth
        Positioned(
          right: -80,
          top: 50,
          child: Container(
            width: 350,
            height: 350,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  SliceColors.primaryPurple.withOpacity(0.15),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
        // Optional: Add floating 3D decorative elements
        Positioned(
          right: -50,
          top: 100,
          child: Opacity(
            opacity: 0.5,
            child: Image.asset('assets/3d_deco.png', width: 300),
          ),
        ),
        Center(child: child),
      ],
    ),
  );
}
```

## Glossy & Transparent UI Patterns

All surfaces use a dark glass aesthetic -- semi-transparent layers with specular highlights that simulate light reflecting off glossy material.

### 1. Glossy Dark Card (Specular Highlight)

Cards have a subtle top-edge sheen simulating a glossy surface reflecting ambient light:

```dart
Widget glossyCard({
  required Widget child,
  double? width,
  double? height,
  EdgeInsets? padding,
  double borderRadius = 24,
  Color? tint,
}) {
  return Container(
    width: width,
    height: height,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(borderRadius),
      // Layer 1: Dark translucent base
      color: SliceColors.glassDark,
      // Layer 2: Top-edge specular highlight (glossy sheen)
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          SliceColors.sheenTop,    // Glossy highlight at top
          SliceColors.glassDark,   // Translucent body
          SliceColors.sheenBottom, // Subtle fade at bottom
        ],
        stops: [0.0, 0.3, 1.0],
      ),
      border: Border.all(
        color: SliceColors.glassDarkBorder,
        width: 1,
      ),
      boxShadow: [
        // Outer soft glow
        BoxShadow(
          color: SliceColors.edgeGlow.withOpacity(0.15),
          blurRadius: 30,
          spreadRadius: -5,
        ),
        // Inner depth shadow
        BoxShadow(
          color: Colors.black.withOpacity(0.3),
          blurRadius: 20,
          inset: true,
        ),
      ],
    ),
    child: ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius - 2),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          padding: padding ?? EdgeInsets.all(SliceSpacing.lg),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(borderRadius - 2),
            color: (tint ?? Colors.white).withOpacity(0.03),
          ),
          child: child,
        ),
      ),
    ),
  );
}
```

### 2. Translucent Bottom Sheet (Dark Gloss)

```dart
Widget darkGlossSheet({required Widget child}) {
  return Container(
    decoration: BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFF1A1A26).withOpacity(0.85),
          Color(0xFF12121A).withOpacity(0.95),
        ],
      ),
      borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      border: Border(
        top: BorderSide(color: SliceColors.glassDarkBorder, width: 1),
      ),
    ),
    child: ClipRRect(
      borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
        child: Container(
          padding: EdgeInsets.all(SliceSpacing.xl),
          // Specular highlight line at top
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment(0, 0.1),
              colors: [
                SliceColors.sheenTop.withOpacity(0.3),
                Colors.transparent,
              ],
            ),
          ),
          child: child,
        ),
      ),
    ),
  );
}
```

### 3. Transparent Navigation Bar (Floating Glass)

```dart
Widget glassNavBar({
  required int currentIndex,
  required Function(int) onTap,
  required List<NavItem> items,
}) {
  return SafeArea(
    child: Padding(
      padding: EdgeInsets.all(SliceSpacing.md),
      child: Container(
        height: 64,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              SliceColors.sheenTop.withOpacity(0.15),
              SliceColors.glassDark.withOpacity(0.4),
            ],
          ),
          borderRadius: BorderRadius.circular(SliceSpacing.radiusFull),
          border: Border.all(
            color: SliceColors.glassDarkBorder,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.4),
              blurRadius: 30,
              spreadRadius: -10,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(SliceSpacing.radiusFull),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: items.asMap().entries.map((entry) {
                final idx = entry.key;
                final item = entry.value;
                final isActive = idx == currentIndex;
                return GestureDetector(
                  onTap: () => onTap(idx),
                  child: AnimatedContainer(
                    duration: Duration(milliseconds: 200),
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: isActive ? BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          SliceColors.primaryMagenta.withOpacity(0.3),
                          SliceColors.primaryPurple.withOpacity(0.3),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(SliceSpacing.radiusFull),
                      border: Border.all(
                        color: SliceColors.primaryMagenta.withOpacity(0.4),
                        width: 1,
                      ),
                    ) : null,
                    child: Icon(
                      item.icon,
                      color: isActive
                          ? SliceColors.primaryMagenta
                          : SliceColors.textMuted,
                      size: 24,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ),
    ),
  );
}
```

### 4. Glossy Button (Shine Effect)

Buttons with a light streak across the top half for a wet/glossy look:

```dart
Widget glossyButton(
  String text,
  VoidCallback onPressed, {
  bool isPrimary = true,
  double height = 52,
}) {
  return GestureDetector(
    onTap: onPressed,
    child: Container(
      height: height,
      padding: EdgeInsets.symmetric(horizontal: 32),
      decoration: BoxDecoration(
        gradient: isPrimary ? LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            SliceColors.primaryMagenta.withOpacity(0.9),
            SliceColors.primaryPurple,
            SliceColors.primaryPurple.withOpacity(0.8),
          ],
        ) : null,
        color: isPrimary ? null : SliceColors.glassDark,
        borderRadius: BorderRadius.circular(SliceSpacing.radiusFull),
        border: Border.all(
          color: isPrimary
              ? SliceColors.primaryMagenta.withOpacity(0.5)
              : SliceColors.glassDarkBorder,
          width: 1,
        ),
        // Specular highlight overlay on top half
        boxShadow: isPrimary ? [
          BoxShadow(
            color: SliceColors.primaryMagenta.withOpacity(0.4),
            blurRadius: 20,
            spreadRadius: -5,
          ),
        ] : [],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Shine effect across top
          if (isPrimary)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: height * 0.45,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.white.withOpacity(0.25),
                      Colors.white.withOpacity(0.0),
                    ],
                  ),
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(SliceSpacing.radiusFull),
                  ),
                ),
              ),
            ),
          Text(
            text,
            style: SliceTypography.body.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    ),
  );
}
```

### 5. Floating Glass Panel (Ambient Glow)

Panels that hover with a soft colored glow underneath:

```dart
Widget floatingGlassPanel({
  required Widget child,
  double? width,
  Color? glowColor,
  double borderRadius = 24,
}) {
  final glow = glowColor ?? SliceColors.primaryPurple;
  return Container(
    width: width,
    decoration: BoxDecoration(
      // Ambient glow behind the panel
      boxShadow: [
        BoxShadow(
          color: glow.withOpacity(0.2),
          blurRadius: 40,
          spreadRadius: 0,
          offset: Offset(0, 8),
        ),
        BoxShadow(
          color: Colors.black.withOpacity(0.4),
          blurRadius: 30,
          spreadRadius: -10,
        ),
      ],
    ),
    child: ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
        child: Container(
          padding: EdgeInsets.all(SliceSpacing.lg),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                SliceColors.sheenTop.withOpacity(0.12),
                SliceColors.glassDark.withOpacity(0.3),
              ],
            ),
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(
              color: SliceColors.glassDarkBorder,
              width: 1.5,
            ),
          ),
          child: child,
        ),
      ),
    ),
  );
}
```

### 6. Gradient Border Glow Card

Cards with a rotating gradient border effect for featured/premium content:

```dart
class GradientBorderCard extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final double borderWidth;
  final List<Color> gradientColors;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradientColors,
        ),
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          BoxShadow(
            color: gradientColors.first.withOpacity(0.3),
            blurRadius: 25,
            spreadRadius: -5,
          ),
        ],
      ),
      padding: EdgeInsets.all(borderWidth),
      child: Container(
        decoration: BoxDecoration(
          color: SliceColors.bgDarkCard,
          borderRadius: BorderRadius.circular(borderRadius - borderWidth),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(borderRadius - borderWidth),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              padding: EdgeInsets.all(SliceSpacing.lg),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}
```

### 7. Liquid Glass Background (Page-level)

Apply to Scaffold body for a deep translucent page background:

```dart
Widget liquidGlassBackground({required Widget child}) {
  return Container(
    decoration: BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          SliceColors.bgDark,
          SliceColors.bgDarkElevated,
          SliceColors.bgDark,
        ],
      ),
    ),
    child: Stack(
      children: [
        // Ambient color orbs (decorative, blurred)
        Positioned(
          top: -100,
          right: -100,
          child: Container(
            width: 400,
            height: 400,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  SliceColors.primaryPurple.withOpacity(0.2),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
        Positioned(
          bottom: -50,
          left: -50,
          child: Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  SliceColors.primaryMagenta.withOpacity(0.15),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
        // Content
        child,
      ],
    ),
  );
}
```

### 8. Dark Shimmer Loading (Glossy Skeleton)

```dart
Widget darkShimmer({double width = 200, double height = 20, double radius = 8}) {
  return Shimmer.fromColors(
    baseColor: SliceColors.bgDarkCard,
    highlightColor: SliceColors.glassDark.withOpacity(0.6),
    child: Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: SliceColors.bgDarkCard,
        borderRadius: BorderRadius.circular(radius),
      ),
    ),
  );
}
```

## Animation System

### 1. Scroll-Triggered Fade + Slide

```dart
class FadeSlideIn extends StatefulWidget {
  final Widget child;
  final double delay;
  
  @override
  State<FadeSlideIn> createState() => _FadeSlideInState();
}

class _FadeSlideInState extends State<FadeSlideIn> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fade;
  late Animation<Offset> _slide;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );
    _fade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    _slide = Tween<Offset>(begin: Offset(0, 40), end: Offset.zero).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
    
    Future.delayed(Duration(milliseconds: (widget.delay * 1000).toInt()), () {
      if (mounted) _controller.forward();
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: AnimatedBuilder(
        animation: _slide,
        builder: (context, child) => Transform.translate(
          offset: _slide.value,
          child: child,
        ),
        child: widget.child,
      ),
    );
  }
}
```

### 2. Scroll-Reveal using NotificationListener

```dart
Widget scrollReveal({required List<Widget> children}) {
  return NotificationListener<ScrollNotification>(
    onNotification: (scroll) {
      // Trigger animations based on scroll position
      return false;
    },
    child: ListView.builder(
      itemCount: children.length,
      itemBuilder: (context, index) {
        return FadeSlideIn(
          delay: index * 0.15,
          child: children[index],
        );
      },
    ),
  );
}
```

### 3. Parallax Image Effect

```dart
class ParallaxImage extends StatelessWidget {
  final String imageUrl;
  final double height;
  final ScrollController scrollController;
  
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: scrollController,
      builder: (context, child) {
        double offset = scrollController.hasClients ? scrollController.offset : 0;
        return Container(
          height: height,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(SliceSpacing.radiusLg),
          ),
          child: Transform.translate(
            offset: Offset(0, offset * 0.3), // Parallax factor
            child: Image.asset(imageUrl, fit: BoxFit.cover, height: height * 1.4),
          ),
        );
      },
    );
  }
}
```

### 4. Smooth Page Transitions

```dart
// In your MaterialApp -- dark theme as default
MaterialApp(
  themeMode: ThemeMode.dark, // Dark is primary
  darkTheme: ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: SliceColors.bgDark,
    colorScheme: ColorScheme.dark(
      primary: SliceColors.primaryMagenta,
      secondary: SliceColors.primaryPurple,
      surface: SliceColors.bgDarkSurface,
      background: SliceColors.bgDark,
      onSurface: SliceColors.textPrimary,
      onBackground: SliceColors.textPrimary,
    ),
    cardTheme: CardTheme(
      color: SliceColors.bgDarkCard,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(SliceSpacing.radiusLg),
      ),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      iconTheme: IconThemeData(color: SliceColors.textPrimary),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: Colors.transparent,
      elevation: 0,
    ),
    pageTransitionsTheme: PageTransitionsTheme(
      builders: {
        TargetPlatform.android: CupertinoPageTransitionsBuilder(),
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
        TargetPlatform.windows: CupertinoPageTransitionsBuilder(),
        TargetPlatform.linux: CupertinoPageTransitionsBuilder(),
      },
    ),
  ),
  theme: ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: SliceColors.bgLight,
    // Light theme as secondary option
  ),
)
```

### 5. Hero Animations Between Screens

```dart
// Source screen
Hero(
  tag: 'card-image',
  child: ClipRRect(
    borderRadius: BorderRadius.circular(24),
    child: Image.asset('card.png', height: 200),
  ),
);

// Destination screen
Hero(
  tag: 'card-image',
  child: ClipRRect(
    borderRadius: BorderRadius.circular(0),
    child: Image.asset('card.png', height: 400),
  ),
);
```

### 6. Shimmer Loading Effect (like Slice's data loading)

```dart
// Package: shimmer: ^3.0.0
Widget shimmerLoading({double width = 200, double height = 20}) {
  return darkShimmer(width: width, height: height);
}
```

### 7. Animated Counter (for amounts/statistics)

```dart
class AnimatedCounter extends StatelessWidget {
  final double value;
  final String prefix;
  
  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: value),
      duration: Duration(milliseconds: 1200),
      curve: Curves.easeOutCubic,
      builder: (context, val, child) {
        return Text(
          '$prefix${val.toStringAsFixed(0)}',
          style: SliceTypography.amount,
        );
      },
    );
  }
}
```

## Mobile App Patterns

### Bottom Navigation

```dart
// Use glassNavBar() from Glossy section for dark theme
// Mobile quick nav using glass aesthetic:
Widget sliceBottomNav(int currentIndex, Function(int) onTap) {
  return glassNavBar(
    currentIndex: currentIndex,
    onTap: onTap,
    items: [
      NavItem(icon: Icons.home_rounded, label: 'Home'),
      NavItem(icon: Icons.explore_rounded, label: 'Explore'),
      NavItem(icon: Icons.add_circle_rounded, label: 'Create'),
      NavItem(icon: Icons.bar_chart_rounded, label: 'Analytics'),
      NavItem(icon: Icons.person_rounded, label: 'Profile'),
    ],
  );
}
```

### Balance/Amount Card (Mobile)

```dart
Widget balanceCard({required double balance, required String label}) {
  return glossyCard(
    padding: EdgeInsets.all(SliceSpacing.lg),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: SliceTypography.caption.copyWith(color: SliceColors.textMuted)),
        SizedBox(height: SliceSpacing.sm),
        AnimatedCounter(value: balance, prefix: '\u20B9'),
        SizedBox(height: SliceSpacing.sm),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                SliceColors.success.withOpacity(0.15),
                SliceColors.success.withOpacity(0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(SliceSpacing.radiusFull),
            border: Border.all(
              color: SliceColors.success.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.trending_up, size: 16, color: SliceColors.success),
              SizedBox(width: 4),
              Text('+2.4%', style: TextStyle(
                color: SliceColors.success,
                fontWeight: FontWeight.w600,
              )),
            ],
          ),
        ),
      ],
    ),
  );
}
```

### Spending Categories with Progress Bars

```dart
Widget categoryRow({
  required IconData icon,
  required Color iconColor,
  required String label,
  required double amount,
  required double percent,
}) {
  return Padding(
    padding: EdgeInsets.symmetric(vertical: SliceSpacing.sm),
    child: Row(
      children: [
        Container(
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(SliceSpacing.radiusMd),
          ),
          child: Icon(icon, color: iconColor, size: 20),
        ),
        SizedBox(width: SliceSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(label, style: SliceTypography.body),
                  Text('\u20B9${amount.toStringAsFixed(0)}', style: SliceTypography.body.copyWith(fontWeight: FontWeight.w600)),
                ],
              ),
              SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: percent / 100,
                  backgroundColor: iconColor.withOpacity(0.1),
                  valueColor: AlwaysStoppedAnimation(iconColor),
                  minHeight: 6,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
```

### Analytics Line Chart (with gradient fill)

```dart
// Use fl_chart: ^0.68.0
Widget analyticsChart(List<FlSpot> spots) {
  return LineChart(
    LineChartData(
      gridData: FlGridData(show: false),
      titlesData: FlTitlesData(show: false),
      borderData: FlBorderData(show: false),
      lineBarsData: [
        LineChartBarData(
          spots: spots,
          isCurved: true,
          curveSmoothness: 0.4,
          barWidth: 3,
          color: SliceColors.primaryMagenta,
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                SliceColors.primaryMagenta.withOpacity(0.3),
                SliceColors.primaryMagenta.withOpacity(0.0),
              ],
            ),
          ),
          dotData: FlDotData(
            show: true,
            getDotPainter: (spot, percent, bar, index) => FlDotCirclePainter(
              radius: 6,
              color: SliceColors.primaryMagenta,
              strokeWidth: 3,
              strokeColor: Colors.white,
            ),
          ),
        ),
      ],
    ),
  );
}
```

## Responsive Patterns

### Adaptive Layout Switcher

```dart
class AdaptiveLayout extends StatelessWidget {
  final Widget mobile;
  final Widget desktop;
  
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 900) return desktop;
        return mobile;
      },
    );
  }
}
```

### Desktop-Specific Patterns
- **Side Navigation**: Vertical nav rail instead of bottom bar
- **Multi-Column Grids**: 2-3 column feature card layouts
- **Max Content Width**: Center content with `SliceSpacing.maxContentWidth`
- **Horizontal Padding**: `SliceSpacing.desktopPadding` (48px)
- **Large Hero Images**: Full-width with parallax

### Mobile-Specific Patterns
- **Bottom Navigation**: 5-tab with center-prominent action
- **Stack Layout**: Single column, full-width cards
- **Compact Padding**: `SliceSpacing.mobilePadding` (16px)
- **Sheet Modals**: Bottom sheets for actions/details
- **Swipe Gestures**: Horizontal swipe between tabs

### Tablet Adaptations
- **2-Column Grid**: Cards in 2-column layout
- **Persistent Nav**: Side rail or extended bottom nav
- **Medium Hero**: 450px height with adjusted typography

## Page Structure Templates

### Desktop Page Template

```dart
class DesktopPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SliceColors.bgDark,
      body: liquidGlassBackground(
        child: CustomScrollView(
          slivers: [
            // Glass app bar with blur
            SliverAppBar(
              floating: true,
              backgroundColor: SliceColors.bgDark.withOpacity(0.7),
              elevation: 0,
              flexibleSpace: ClipRRect(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                  child: Container(color: Colors.transparent),
                ),
              ),
              title: Image.asset('logo.png', height: 32),
              actions: [
                glossyButton('Get Started', () {}),
                SizedBox(width: SliceSpacing.lg),
              ],
            ),
            SliverToBoxAdapter(child: heroSection(...)),
            SliverToBoxAdapter(child: SizedBox(height: SliceSpacing.xxxl)),
            SliverToBoxAdapter(child: featureGrid(...)),
            SliverToBoxAdapter(child: SizedBox(height: SliceSpacing.xxxl)),
            SliverToBoxAdapter(child: gradientShowcaseSection(...)),
            SliverToBoxAdapter(child: SizedBox(height: SliceSpacing.xxxl)),
            SliverToBoxAdapter(child: footerSection(...)),
          ],
        ),
      ),
    );
  }
}
```

### Mobile Page Template

```dart
class MobilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SliceColors.bgDark,
      extendBody: true, // Allows content to flow behind glass nav
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Image.asset('logo_dark.png', height: 28),
        actions: [
          IconButton(
            icon: Icon(Icons.menu, color: SliceColors.textPrimary),
            onPressed: () {},
          ),
        ],
      ),
      body: liquidGlassBackground(
        child: SingleChildScrollView(
          child: Column(
            children: [
              mobileHero(...),
              SizedBox(height: SliceSpacing.xl),
              featureCardsList(...),
              SizedBox(height: SliceSpacing.xl),
              analyticsSection(...),
              // Bottom padding for glass nav
              SizedBox(height: 100),
            ],
          ),
        ),
      ),
      bottomNavigationBar: sliceBottomNav(0, (i) {}),
    );
  }
}
```

## Required Flutter Packages

```yaml
dependencies:
  flutter:
    sdk: flutter
  
  # Animations
  flutter_animate: ^4.5.0
  shimmer: ^3.0.0
  lottie: ^3.1.0
  
  # Charts
  fl_chart: ^0.68.0
  
  # Images & blur
  cached_network_image: ^3.4.0
  glass_kit: ^4.0.1
  
  # Responsive
  flutter_screenutil: ^5.9.0
  
  # Icons
  phosphor_flutter: ^2.1.0
  
  # Scroll effects
  scroll_snap_list: ^0.9.1
```

## Key Implementation Notes

1. **Dark Mode is Default**: Set `ThemeMode.dark` in MaterialApp. All components assume a dark background. Light mode support is secondary.

2. **Glossy Surface Rendering**: Achieve the glossy look by stacking three layers on every card: (a) translucent dark base, (b) top-edge specular highlight gradient (`sheenTop` to transparent), (c) subtle inner shadow. Always combine `BackdropFilter` + gradient overlay.

3. **Ambient Glow Orbs**: Place large blurred circles (`RadialGradient` with low opacity) behind content areas using `Stack`. This creates depth and visual interest on dark backgrounds without heavy imagery.

4. **Glassmorphism Performance**: On web/desktop, `BackdropFilter` can be expensive. Limit to 2-3 instances per viewport. Use `Container` with semi-transparent gradient as fallback. Consider `Opacity` animations to fade glass layers in/out instead of constant blur.

5. **Edge Glow for Premium Content**: Use `GradientBorderCard` for featured/premium sections. The colored border + outer glow signals importance in the dark UI.

6. **Transparency Hierarchy**: Background > Ambient glow orbs (most transparent) > Glass cards (medium transparency) > Solid content (least transparent). Maintain this layering for visual depth.

7. **Watercolor Aesthetic**: Apply a subtle watercolor/painterly filter to all photographic imagery using `ColorFilter` with `BlendMode` or pre-process assets. Darken images to match the dark theme.

8. **3D Decorative Elements**: Use pre-rendered PNG assets with transparency. Position absolutely with `Stack` + `Positioned`. Add subtle `AnimationController` for floating motion.

9. **Typography Loading**: Use `google_fonts` package for Inter/Geist, or self-host font files. Preload fonts in `pubspec.yaml`. Ensure white/light text has sufficient contrast on dark surfaces.

10. **Scroll Animations**: For web, use `IntersectionObserver` pattern via `VisibilityDetector` package. Trigger animations when widgets enter viewport.

11. **Hero Animations**: Only animate common visual elements (images, cards). Avoid hero-ing text between different font sizes.

12. **State Management**: Use Riverpod or BLoC for animation state. Keep animation controllers in StatefulWidgets, dispose properly.

## Adaptation Guide (Non-Banking Use)

Since this is NOT a banking application:

| Slice Element | Adaptation |
|---|---|
| Balance/Amount cards | User metrics, scores, progress, counts |
| Spending categories | Activity types, content categories, feature usage |
| Credit card visuals | Product/feature showcase cards |
| Transaction lists | Activity feeds, notification lists, content streams |
| "Trusted by 20mn+" | User count, download stats, community size |
| Savings/Interest language | Growth metrics, achievements, streaks |
| QR Scanner center button | Primary action button (create, share, search) |
| Banking tab labels | Your app's core feature names |

Maintain Slice's visual language (bold type, glass cards, vibrant gradients, smooth animations) while replacing all financial content with your app's domain-specific content.