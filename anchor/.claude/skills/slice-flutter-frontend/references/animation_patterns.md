# Animation Patterns Reference

## 0. Dark Theme Animation Considerations

When animating in dark glossy UIs:
- Use `Curves.easeOutCubic` for entrance animations -- feels premium and smooth
- Animate opacity of glass layers to avoid jarring blur transitions
- Glow intensities should pulse subtly, never flash brightly
- White/light elements should fade in gently to avoid harsh contrast jumps

## 1. Floating 3D Elements

Slice uses floating decorative 3D objects. Implement in Flutter:

```dart
class FloatingElement extends StatefulWidget {
  final Widget child;
  final double amplitude;
  final Duration duration;
  
  @override
  State<FloatingElement> createState() => _FloatingElementState();
}

class _FloatingElementState extends State<FloatingElement> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _float;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    )..repeat(reverse: true);
    
    _float = Tween<double>(begin: -widget.amplitude, end: widget.amplitude).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _float,
      builder: (context, child) => Transform.translate(
        offset: Offset(0, _float.value),
        child: child,
      ),
      child: widget.child,
    );
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
```

## 2. Scroll-Linked Header Collapse

```dart
class CollapsibleHeader extends StatelessWidget {
  final ScrollController controller;
  final double maxHeight;
  final double minHeight;
  
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        double scrollPercent = (controller.offset / (maxHeight - minHeight)).clamp(0, 1);
        double currentHeight = maxHeight - (maxHeight - minHeight) * scrollPercent;
        
        return Container(
          height: currentHeight,
          color: Colors.white.withOpacity(scrollPercent * 0.9),
          child: SafeArea(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Opacity(
                opacity: 1 - scrollPercent,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Large hero content
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
```

## 3. Staggered Grid Animation

```dart
class StaggeredGrid extends StatelessWidget {
  final List<Widget> children;
  final int crossAxisCount;
  
  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: 1.2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: children.length,
      itemBuilder: (context, index) {
        return children[index].animate()
          .fadeIn(delay: (index * 100).ms, duration: 600.ms)
          .slideY(begin: 30, end: 0, delay: (index * 100).ms, duration: 600.ms, curve: Curves.easeOutCubic);
      },
    );
  }
}
```

## 4. Page Transition Animations

```dart
// Slide-up transition
Route createSlideUpRoute(Widget page) {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => page,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      const begin = Offset(0, 1);
      const end = Offset.zero;
      const curve = Curves.easeOutCubic;
      
      var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
      var offsetAnimation = animation.drive(tween);
      
      return SlideTransition(position: offsetAnimation, child: child);
    },
    transitionDuration: Duration(milliseconds: 400),
  );
}

// Scale + fade transition
Route createScaleRoute(Widget page) {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => page,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return ScaleTransition(
        scale: Tween<double>(begin: 0.95, end: 1).animate(
          CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
        ),
        child: FadeTransition(
          opacity: animation,
          child: child,
        ),
      );
    },
    transitionDuration: Duration(milliseconds: 300),
  );
}
```

## 5. Tab Content Switch Animation

```dart
class AnimatedTabContent extends StatelessWidget {
  final int selectedIndex;
  final List<Widget> children;
  
  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: Duration(milliseconds: 400),
      transitionBuilder: (child, animation) {
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: Offset(0.05, 0),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          ),
        );
      },
      child: Container(
        key: ValueKey<int>(selectedIndex),
        child: children[selectedIndex],
      ),
    );
  }
}
```

## 6. Pull-to-Refresh with Custom Indicator

```dart
Widget customRefresh({required Widget child, required Future<void> Function() onRefresh}) {
  return RefreshIndicator(
    onRefresh: onRefresh,
    color: SliceColors.primaryMagenta,
    backgroundColor: Colors.white,
    displacement: 60,
    strokeWidth: 3,
    child: child,
  );
}
```

## 7. Skeleton Loading Screen

```dart
Widget skeletonScreen() {
  return Shimmer.fromColors(
    baseColor: Colors.grey[300]!,
    highlightColor: Colors.grey[100]!,
    child: ListView.builder(
      itemCount: 6,
      itemBuilder: (context, index) {
        return Container(
          margin: EdgeInsets.all(16),
          height: 120,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
        );
      },
    ),
  );
}
```

## 8. Notification Badge Animation

```dart
class AnimatedBadge extends StatelessWidget {
  final int count;
  final Widget child;
  
  @override
  Widget build(BuildContext context) {
    return Badge(
      label: AnimatedSwitcher(
        duration: Duration(milliseconds: 200),
        transitionBuilder: (child, animation) {
          return ScaleTransition(scale: animation, child: child);
        },
        child: Text(
          '$count',
          key: ValueKey<int>(count),
          style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
        ),
      ),
      backgroundColor: SliceColors.primaryMagenta,
      child: child,
    );
  }
}
```

## 9. Gradient Text Animation

```dart
class GradientText extends StatelessWidget {
  final String text;
  final TextStyle style;
  final Gradient gradient;
  
  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (bounds) {
        return gradient.createShader(Rect.fromLTWH(0, 0, bounds.width, bounds.height));
      },
      child: Text(text, style: style.copyWith(color: Colors.white)),
    );
  }
}

// Usage with animation:
GradientText(
  'Do right by the money',
  style: SliceTypography.hero.copyWith(fontSize: 64),
  gradient: LinearGradient(
    colors: [SliceColors.primaryMagenta, SliceColors.primaryLime],
  ),
).animate().fadeIn(duration: 800.ms).slideY(begin: 20, end: 0, duration: 800.ms);
```

## 10. Bottom Sheet Entrance (Dark Gloss)

```dart
void showSliceBottomSheet(BuildContext context, Widget content) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (context) {
      return darkGlossSheet(
        child: content.animate().slideY(
          begin: 50, end: 0, duration: 400.ms, curve: Curves.easeOutCubic,
        ).fadeIn(duration: 300.ms),
      );
    },
  );
}
```

## 11. Glossy Card Entrance Animation

Cards should slide up and their glass sheen should animate in separately:

```dart
class GlossyCardEntrance extends StatelessWidget {
  final Widget child;
  final int index;
  
  @override
  Widget build(BuildContext context) {
    return child
      .animate()
      .fadeIn(delay: (index * 120).ms, duration: 600.ms)
      .slideY(begin: 40, end: 0, delay: (index * 120).ms, duration: 600.ms, curve: Curves.easeOutCubic)
      .scale(begin: Offset(0.97, 0.97), end: Offset(1, 1), delay: (index * 120).ms, duration: 600.ms);
  }
}
```

## 12. Ambient Glow Pulse

Subtle pulsing glow for featured cards or active elements:

```dart
class GlowPulse extends StatefulWidget {
  final Widget child;
  final Color glowColor;
  
  @override
  State<GlowPulse> createState() => _GlowPulseState();
}

class _GlowPulseState extends State<GlowPulse> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _pulse;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: 3000),
      vsync: this,
    )..repeat(reverse: true);
    
    _pulse = Tween<double>(begin: 0.1, end: 0.25).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulse,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: widget.glowColor.withOpacity(_pulse.value),
                blurRadius: 40,
                spreadRadius: -5,
              ),
            ],
          ),
          child: child,
        );
      },
      child: widget.child,
    );
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
```

## 13. Sheen Sweep Animation

A light streak that sweeps across glossy cards for a "premium shine" effect:

```dart
class SheenSweep extends StatefulWidget {
  final Widget child;
  final double width;
  final double height;
  
  @override
  State<SheenSweep> createState() => _SheenSweepState();
}

class _SheenSweepState extends State<SheenSweep> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: 2000),
      vsync: this,
    );
    // Trigger once on mount
    Future.delayed(Duration(milliseconds: 500), () {
      if (mounted) _controller.forward();
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Positioned.fill(
              child: ShaderMask(
                shaderCallback: (bounds) {
                  return LinearGradient(
                    begin: Alignment(-1.5 + _controller.value * 3, 0),
                    end: Alignment(-0.5 + _controller.value * 3, 0),
                    colors: [
                      Colors.transparent,
                      Colors.white.withOpacity(0.15),
                      Colors.transparent,
                    ],
                    stops: [0.0, 0.5, 1.0],
                  ).createShader(bounds);
                },
                blendMode: BlendMode.srcATop,
                child: Container(
                  width: widget.width,
                  height: widget.height,
                  color: Colors.white.withOpacity(0.1),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
```

## 14. Glass Fade Transition

For navigating between glass-heavy screens -- fade with slight blur shift:

```dart
Route createGlassRoute(Widget page) {
  return PageRouteBuilder(
    opaque: false,
    pageBuilder: (context, animation, secondaryAnimation) => page,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(
        opacity: CurvedAnimation(
          parent: animation,
          curve: Curves.easeOut,
        ),
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: Tween<double>(begin: 10, end: 0).evaluate(animation),
            sigmaY: Tween<double>(begin: 10, end: 0).evaluate(animation),
          ),
          child: child,
        ),
      );
    },
    transitionDuration: Duration(milliseconds: 400),
  );
}

```dart
void showSliceBottomSheet(BuildContext context, Widget content) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (context) {
      return Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        padding: EdgeInsets.all(24),
        child: content.animate().slideY(
          begin: 50, end: 0, duration: 400.ms, curve: Curves.easeOutCubic,
        ).fadeIn(duration: 300.ms),
      );
    },
  );
}
```

## Timing Reference

| Animation Type | Duration | Easing | Delay |
|---|---|---|---|
| Page transition | 300-400ms | easeOutCubic | 0 |
| Element fade-in | 600-800ms | easeOut | 100-200ms stagger |
| Tab switch | 300ms | easeInOut | 0 |
| Counter animate | 1000-1500ms | easeOutCubic | 0 |
| Floating element | 3000-5000ms | easeInOutSine | 0 (loop) |
| Bottom sheet | 400ms | easeOutCubic | 0 |
| Shimmer loading | 1500ms | linear | 0 (loop) |
| Hero animation | 300-450ms | fastOutSlowIn | 0 |
| Scale on press | 150ms | easeOut | 0 |
| Scroll parallax | real-time | linear | 0 |
| Glossy card entrance | 600ms | easeOutCubic | 120ms stagger |
| Glow pulse | 3000ms | easeInOutSine | 0 (loop) |
| Sheen sweep | 2000ms | easeInOut | 500ms |
| Glass route transition | 400ms | easeOut | 0 |
