# Widget Catalog

Quick reference for all Slice-inspired widgets. Import from your project's design system.

## Dark Theme Foundation

| Widget | Purpose |
|---|---|
| `liquidGlassBackground()` | Page-level dark background with ambient glow orbs |
| `glassNavBar()` | Translucent floating bottom navigation |

## Glossy & Transparent Widgets

| Widget | Purpose | Visual Effect |
|---|---|---|
| `glossyCard()` | Primary card component | Specular highlight top, translucent body, soft glow |
| `darkGlossSheet()` | Bottom sheet | Gradient dark glass with top-edge sheen |
| `floatingGlassPanel()` | Hovering info panels | Backdrop blur + ambient glow shadow |
| `glossyButton()` | Primary CTA button | Gradient fill + top-half shine streak |
| `gradientBorderCard()` | Featured/premium card | Colored gradient border + outer glow |
| `darkShimmer()` | Loading placeholder | Dark shimmer with glass highlight |

## Layout Widgets

| Widget | Purpose | Desktop | Mobile |
|---|---|---|---|
| `heroSection()` | Full-bleed hero with overlay text | 600px height, text centered | 350px height, text below |
| `gradientSection()` | Full-width gradient background | Full viewport | Full viewport |
| `featureShowcase()` | Tabbed feature demo | Side-by-side layout | Stacked layout |
| `AdaptiveLayout()` | Responsive switcher | desktop widget | mobile widget |
| `glassCard()` | Frosted glass container | Up to 3 per row | Full width |

## Button Widgets

| Widget | Usage |
|---|---|
| `glossyButton()` | Primary CTA -- gradient fill + shine |
| `glossyButton(isPrimary: false)` | Secondary CTA -- glass dark |
| `pillButton()` | Legacy simple pill (use glossyButton instead) |
| `IconButton` with glass bg | Action buttons in cards |

## Card Widgets

| Widget | Purpose |
|---|---|
| `glossyCard()` | **Primary** -- Glass card with specular sheen |
| `balanceCard()` | Display metrics/amounts (uses glossyCard) |
| `glassCard()` | Frosted glass without sheen |
| `featureCard()` | Icon + title + description |
| `categoryCard()` | Progress bar + icon + label |
| `gradientBorderCard()` | Featured content with colored border glow |

## Navigation

| Widget | Desktop | Mobile |
|---|---|---|
| `SliverAppBar` + blur | Fixed top with glass effect | Collapsible |
| `glassNavBar()` | Hidden | Floating translucent bottom bar |
| `sideNavigationRail()` | Vertical glass rail | Hidden |
| `mobileMenuSheet()` | Hidden | Dark gloss bottom sheet |

## Data Display

| Widget | Purpose |
|---|---|
| `AnimatedCounter()` | Animated number counting |
| `analyticsChart()` | Line chart with gradient fill (magenta on dark) |
| `categoryRow()` | Category with progress bar |
| `darkShimmer()` | **Primary** -- Dark glossy skeleton |
| `AnimatedBadge()` | Notification count |

## Animation Wrappers

| Widget | Effect |
|---|---|
| `FadeSlideIn()` | Fade + slide up on mount |
| `FloatingElement()` | Gentle float loop |
| `ParallaxImage()` | Scroll-linked parallax |
| `StaggeredGrid()` | Staggered entrance |
| `AnimatedTabContent()` | Cross-fade tab switch |
| `GradientText()` | Gradient-colored text |

## Mobile-Specific

| Widget | Purpose |
|---|---|
| `mobileHero()` | Compact hero for small screens |
| `featureCardsList()` | Vertical scrollable card list |
| `showSliceBottomSheet()` | Dark gloss bottom sheet |
| `pullToRefresh()` | Custom refresh indicator |
| `swipeableCard()` | Horizontal swipe actions |

## Desktop-Specific

| Widget | Purpose |
|---|---|
| `desktopHero()` | Large hero with side content |
| `featureGrid()` | 2-3 column grid layout |
| `footerSection()` | Multi-column footer |
| `sideBySideShowcase()` | Image left, content right |

## Glossy Effect Quick Reference

| Effect | Implementation |
|---|---|
| Specular sheen (top) | `LinearGradient` from `sheenTop` to transparent, top 30% |
| Ambient glow | `BoxShadow` with brand color at 15-20% opacity, blur 30-40 |
| Glass body | `BackdropFilter(blur)` + `Container` at 3-5% white |
| Edge glow | `BoxShadow` with magenta/purple at 30% opacity |
| Inner depth | `BoxShadow` with black at 30%, `inset: true` |
| Top shine on buttons | Half-height `Container` with white 25% to 0% gradient |

## Color Usage Guide (Dark Theme)

| Element | Color |
|---|---|
| Page background | `SliceColors.bgDark` |
| Card surface | `SliceColors.glassDark` + sheen gradient |
| Primary brand | `SliceColors.primaryMagenta` |
| CTA buttons | Magenta-to-purple gradient + shine |
| Positive/growth | `SliceColors.success` |
| Text primary | `SliceColors.textPrimary` (white) |
| Text secondary | `SliceColors.textSecondary` (muted gray-blue) |
| Text muted | `SliceColors.textMuted` |
| Glass highlight | `SliceColors.sheenTop` |
| Ambient glow | `SliceColors.primaryPurple` at 15-20% opacity |
| Border | `SliceColors.glassDarkBorder` |

## Typography Guide

| Element | Style | Size | Weight |
|---|---|---|---|
| Hero headline | `SliceTypography.hero` | 56-72px | 800 |
| Section title | `SliceTypography.h1` | 40px | 700 |
| Card title | `SliceTypography.h2` | 32px | 700 |
| Body text | `SliceTypography.bodyLarge` | 18px | 400 |
| Amount display | `SliceTypography.amount` | 48px | 700 |
| Tab label | `SliceTypography.tabLabel` | 14px | 600 |
| Caption | `SliceTypography.caption` | 14px | 500 |
