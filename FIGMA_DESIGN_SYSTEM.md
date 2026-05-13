# Codekata — Figma Design System Rules

> Rules for Claude (MCP) when translating Figma designs into this Flutter codebase.
> Reference this document whenever importing or implementing a Figma design.

---

## 1. Platform & Framework

| Layer | Technology |
|---|---|
| UI Framework | Flutter (Dart) — `lib/` |
| State management | Riverpod (`flutter_riverpod ^2.6.1`) |
| Routing | GoRouter (`go_router ^14.8.1`) |
| Animations | `flutter_animate ^4.5.2` + hand-rolled `AnimationController` |
| Material version | Material 3 (`useMaterial3: true`) |
| Target platforms | iOS (primary), Android, Web |

**No CSS, no HTML.** All styling is done via Flutter's `BoxDecoration`, `TextStyle`, `Theme`, and `CustomPainter`. When reading Figma, map visual properties directly to Flutter equivalents.

---

## 2. Design Tokens

### 2.1 Color Palette

**Source:** `lib/core/theme/app_colors.dart` — `abstract final class AppColors`

All colors are `const Color(0xFFRRGGBB)`.

#### Brand / Primary — Electric Blue
```dart
AppColors.primary        = Color(0xFF1A8CFF)  // main CTA, active states
AppColors.primaryDark    = Color(0xFF0066CC)  // shadow base, gradient end
AppColors.primaryLight   = Color(0xFFC8E4FF)  // tint backgrounds
AppColors.primarySurface = Color(0xFFEEF6FF)  // chip/badge fills on light
```

#### XP Gold — Streak & Rewards
```dart
AppColors.gold      = Color(0xFFF5A623)
AppColors.goldDark  = Color(0xFFC97E10)
AppColors.goldLight = Color(0xFFFEF3DA)
```

#### Semantic Colors
```dart
// Success (teal-green)
AppColors.success      = Color(0xFF2EC37A)
AppColors.successDark  = Color(0xFF1F8F58)
AppColors.successLight = Color(0xFFD4F2E3)

// Error (Apple-desaturated red)
AppColors.error      = Color(0xFFF14A59)
AppColors.errorDark  = Color(0xFFC62330)
AppColors.errorLight = Color(0xFFFDE2E5)

// Warning orange
AppColors.warning      = Color(0xFFFF9600)
AppColors.warningLight = Color(0xFFFFF0D4)
```

#### Surfaces & Text — Light Mode
```dart
AppColors.bg          = Color(0xFFF7F9FF)  // scaffold background
AppColors.surface     = Color(0xFFFFFFFF)  // cards, sheets
AppColors.surfaceAlt  = Color(0xFFEEF1F8)  // secondary surfaces
AppColors.border      = Color(0xFFD8E0EF)  // hairline borders
AppColors.borderStrong = Color(0xFFB0BDD8) // emphasized borders

AppColors.textPrimary   = Color(0xFF1A1F2E)
AppColors.textSecondary = Color(0xFF6B7A99)
AppColors.textDisabled  = Color(0xFFB0B8CC)
AppColors.textOnPrimary = Color(0xFFFFFFFF)
```

#### Dark Mode Overrides
```dart
AppColors.darkBg           = Color(0xFF12141F)
AppColors.darkSurface      = Color(0xFF1C1F30)
AppColors.darkSurfaceAlt   = Color(0xFF222638)
AppColors.darkBorder       = Color(0xFF323752)
AppColors.darkTextPrimary  = Color(0xFFE8EDF8)
AppColors.darkTextSecondary = Color(0xFF8B96B5)
```

#### Code Editor — Dark Canvas
```dart
AppColors.codeBg      = Color(0xFF10121E)  // editor background
AppColors.codeBgAlt   = Color(0xFF1A1D2E)  // gutter / toolbar
AppColors.codeLineHl  = Color(0xFF1F2336)  // active line highlight
AppColors.codeText    = Color(0xFFE2E8F8)
AppColors.codeKeyword = Color(0xFFA78BFA)  // purple
AppColors.codeString  = Color(0xFF6EE7A0)  // green
AppColors.codeNumber  = Color(0xFFFBB86C)  // amber
AppColors.codeComment = Color(0xFF5E6885)
AppColors.codeSlot    = Color(0xFF1A8CFF)  // fill-in-the-blank slot (primary)
```

**Figma mapping rule:** Always check the theme mode (light/dark) from context. Use `Theme.of(context).colorScheme.*` for theme-aware colors; use `AppColors.*` constants only when you need a fixed value (e.g., code editor).

---

### 2.2 Typography

**Source:** `lib/core/theme/app_typography.dart` — `abstract final class AppTypography`

Three font families, loaded via `google_fonts`:

| Role | Font | Weights used |
|---|---|---|
| Display / Headings | **Space Grotesk** | 600, 700 |
| Body / UI | **Inter** | 400, 500, 600 |
| Code editor | **JetBrains Mono** | 400, 500 |

#### Scale
```dart
AppTypography.display  // Space Grotesk 700, 32px, lh 38/32, ls -2%
AppTypography.h1       // Space Grotesk 700, 26px, lh 32/26, ls -2%
AppTypography.h2       // Space Grotesk 600, 20px, lh 26/20, ls -1.5%
AppTypography.h3       // Space Grotesk 600, 17px, lh 22/17, ls -1%

AppTypography.bodyLg   // Inter 500, 16px, lh 24/16, ls -0.5%
AppTypography.body     // Inter 400, 15px, lh 22/15
AppTypography.label    // Inter 600, 13px, lh 18/13
AppTypography.caption  // Inter 500, 12px, lh 16/12
AppTypography.eyebrow  // Inter 600, 11px, lh 14/11, ls +14% (uppercase section labels)

AppTypography.codeBody    // JetBrains Mono 400, 13px, lh 20/13
AppTypography.codeKeyword // JetBrains Mono 500, 13px — purple
AppTypography.codeSlot    // JetBrains Mono 500, 13px — blue + underline
```

**Usage:** Always use `AppTypography.X.copyWith(color: ...)` to apply color. Never override `fontFamily` directly — always extend the predefined styles.

---

### 2.3 Spacing & Radius

**Source:** `lib/core/theme/app_spacing.dart`

#### Spacing (4px base unit)
```dart
AppSpacing.space1  = 4
AppSpacing.space2  = 8
AppSpacing.space3  = 12
AppSpacing.space4  = 16
AppSpacing.space5  = 20
AppSpacing.space6  = 24
AppSpacing.space8  = 32
AppSpacing.space10 = 40
AppSpacing.space12 = 48

AppSpacing.screenPadding       = 16  // horizontal content margin
AppSpacing.bottomNavClearance  = 80  // scroll padding above bottom nav
```

#### Border Radius
```dart
AppRadius.sm   = 8
AppRadius.md   = 12
AppRadius.lg   = 16
AppRadius.xl   = 20   // standard card radius (SurfaceCard, PrimaryCard)
AppRadius.xxl  = 24
AppRadius.full = 9999  // pill / circle (OwlButton, chips)
```

**Figma mapping rule:** Round all spacing to the nearest 4px multiple and map to the closest `AppSpacing` constant. Map Figma corner radii to the closest `AppRadius` constant.

---

## 3. Component Library

All shared widgets live in `lib/core/widgets/`. Below are the key components and how to instantiate them.

### 3.1 `OwlButton` — Primary CTA

File: `lib/core/widgets/owl_button.dart`

```dart
// Primary (electric blue gradient, pill shape, 52px tall)
OwlButton(label: 'Continue', onPressed: () {})

// Success (green gradient)
OwlButton.success(label: 'Submit', onPressed: () {})

// Ghost (transparent, outline border)
OwlButton.ghost(label: 'Skip', onPressed: () {})

// With leading icon
OwlButton(
  label: 'Run Code',
  leading: const CkIcon.run(size: 18, color: Colors.white),
  onPressed: () {},
)
```

**Visual spec:**
- Height: 52px, full-width by default
- Gradient: top-center → bottom-center
  - Primary: `[0xFF3AADFF → 0xFF0B7FE8]`
  - Success: `[0xFF3EE08B → 0xFF15995A]`
- Border: `Colors.white.withValues(alpha: 0.28)`
- Box shadow: two-layer (2px/6px blur + 10px/24px blur) using `primaryDark` at 25–35% alpha
- Press state: `AnimatedScale(0.97)`, shadow reduces
- Disabled: `Opacity(0.45)`, ignores taps

### 3.2 `PrimaryCard` — Hero CTA Card

File: `lib/core/widgets/primary_card.dart`

```dart
PrimaryCard(
  onTap: () => context.push('/unit/$slug'),
  child: _ContinueContent(...),
)
```

**Visual spec:** Electric blue linear gradient (primary → primaryDark), `AppRadius.xl` corners, animated conic shimmer overlay (22s loop, `BlendMode.overlay`), two-layer shadow.

### 3.3 `SurfaceCard` — Neutral Card

File: `lib/core/widgets/primary_card.dart` (same file)

```dart
SurfaceCard(
  onTap: () {},
  padding: const EdgeInsets.all(14),
  child: ...,
)
```

**Visual spec:** `scheme.surface` fill, `AppRadius.xl` corners, `scheme.outline` border, two-layer shadow (4–5% alpha).

### 3.4 `CkIcon` — Custom Icon Set

File: `lib/core/widgets/ck_icons.dart`

Named constructors for each icon; rendered via `CustomPainter` on a 24×24 canvas.

```dart
CkIcon.home(size: 24, color: AppColors.primary)
CkIcon.book(size: 24)
CkIcon.trophy(size: 24)
CkIcon.user(size: 24)
CkIcon.flame(size: 16, color: AppColors.goldDark)
CkIcon.bolt(size: 14)
CkIcon.play(size: 24)
CkIcon.lock(size: 26)
CkIcon.check(size: 28)
CkIcon.chevR(size: 18)
CkIcon.chevL(size: 18)
CkIcon.close(size: 24)
CkIcon.plus(size: 24)
CkIcon.hint(size: 24)
CkIcon.reset(size: 22)
CkIcon.send(size: 24)
CkIcon.run(size: 24)
CkIcon.sun(size: 24)
CkIcon.moon(size: 24)
CkIcon.robot(size: 24)
```

**Style:** Phosphor-inspired, 1.75px stroke, rounded caps/joins, filled variants for `flame`, `bolt`, `play`. `color` defaults to `IconTheme` color if not provided (inherits from context).

### 3.5 `ChapterGlyph` — DSA Topic Icons

File: `lib/core/widgets/chapter_glyph.dart`

Geometric diagram icons (48×48 canvas) representing DSA topics.

```dart
ChapterGlyph(kind: GlyphKind.array,   size: 36, color: AppColors.primary)
ChapterGlyph(kind: GlyphKind.hash,    size: 48)
ChapterGlyph(kind: GlyphKind.pointer, size: 48)
ChapterGlyph(kind: GlyphKind.window,  size: 48)  // sliding window
ChapterGlyph(kind: GlyphKind.stack,   size: 48)
ChapterGlyph(kind: GlyphKind.search,  size: 48)  // binary search
ChapterGlyph(kind: GlyphKind.tree,    size: 48)
ChapterGlyph(kind: GlyphKind.graph,   size: 48)
ChapterGlyph(kind: GlyphKind.neural,  size: 48)
```

### 3.6 `SkillTreeNode` — Skill Tree Circle

File: `lib/core/widgets/skill_tree_node.dart`

72px circle with animated pulse ring for the `current` state.

```dart
SkillTreeNode(
  category: category, // CategoryStatus.locked | current | completed
  onTap: () {},
)
```

**State colors:**
- `locked` → `surfaceAlt` + `outline` border
- `current` → `AppColors.primary` + pulsing ring animation (2s loop)
- `completed` → `AppColors.success`

### 3.7 `CkChip` — Pill Chip

File: `lib/core/widgets/ck_chip.dart`

30px tall pill with optional leading icon.

```dart
CkChip(
  leading: CkIcon.flame(size: 16, color: AppColors.goldDark),
  label: '7 day streak',
  background: AppColors.goldLight,
  foreground: AppColors.goldDark,
)
```

### 3.8 `SectionHeader` — Divider with Label

File: `lib/core/widgets/section_header.dart`

Rule–label–rule layout using `AppTypography.eyebrow`.

```dart
SectionHeader(label: 'Your path')
// Renders as: ─────── YOUR PATH ───────
```

### 3.9 `GlassBar` — Frosted Glass App Bar

File: `lib/core/widgets/glass_bar.dart`

Apple-style `BackdropFilter` blur (sigmaX/Y = 18) with 72% alpha tint and 0.5px bottom border. Used in `HomeScreen` when the user has scrolled past 12px.

```dart
GlassBar(child: _topBarContent())
```

### 3.10 `OwlProgressBar` — Animated Progress Bar

File: `lib/core/widgets/progress_bar.dart`

Red → Yellow → Green gradient based on progress value.

```dart
OwlProgressBar(progress: 0.6, height: 16, showNotches: true)
```

---

## 4. Theme Architecture

**Source:** `lib/core/theme/app_theme.dart`

`AppTheme.light` and `AppTheme.dark` produce `ThemeData` with Material 3. Theme-aware code should always read from `Theme.of(context).colorScheme` rather than hardcoding colors.

Key theme slots:
```dart
colorScheme.primary          // AppColors.primary
colorScheme.secondary        // AppColors.gold
colorScheme.surface          // white / darkSurface
colorScheme.onSurface        // textPrimary
colorScheme.onSurfaceVariant // textSecondary
colorScheme.outline          // border
colorScheme.surfaceContainerHighest // surfaceAlt
```

**Global defaults:**
- `ElevatedButton`: 52px tall, full-width, `AppRadius.xxl` pill, Inter 600 15px
- `OutlinedButton`: 52px tall, `AppRadius.full` pill, outline border
- `Card`: `AppRadius.lg`, `scheme.outline` border, 0 elevation
- `AppBar`: no shadow, no scroll elevation, bg = scaffold bg

---

## 5. Icon System

**Custom icons:** `CkIcon` — `lib/core/widgets/ck_icons.dart`
- 20 icons, 24×24 viewBox, Phosphor-style stroke weight 1.75px
- Rendered via `CustomPainter` — no SVG files, no font glyphs
- Named constructors: `CkIcon.home()`, `CkIcon.flame()`, etc.
- Color inherits from `IconTheme` if not set

**Chapter glyphs:** `ChapterGlyph` — `lib/core/widgets/chapter_glyph.dart`
- 9 glyphs, 48×48 viewBox, stroke weight 1.3–1.5px

**When adding new icons from Figma:**
1. Add a new entry to `enum _IconKind` in `ck_icons.dart`
2. Add a named constructor `CkIcon.myIcon({...})`
3. Add a `case _IconKind.myIcon:` block in `_CkIconPainter.paint()`
4. Draw paths using `canvas.drawPath`, `canvas.drawLine`, `canvas.drawCircle` with the shared `stroke` / `fill` `Paint` objects

**Naming convention:** camelCase matching the visual concept (`chevR`, `chevL`, `bolt`, `run`, `robot`).

---

## 6. Styling Approach

| Concern | Flutter approach |
|---|---|
| Colors | `AppColors.*` constants or `Theme.of(context).colorScheme.*` |
| Typography | `AppTypography.X.copyWith(color: ...)` |
| Spacing | `AppSpacing.*` constants and `SizedBox(height: AppSpacing.space4)` |
| Corner radius | `BorderRadius.circular(AppRadius.*)` |
| Shadows | Two-layer `BoxShadow` (close/soft + far/diffuse) |
| Borders | `Border.all(color: scheme.outline)` or `Border.all(color: AppColors.border)` |
| Gradients | `LinearGradient` (blue CTAs), `SweepGradient` (PrimaryCard shimmer) |
| Dark mode | `Theme.of(context).brightness == Brightness.dark` guard, then `AppColors.dark*` |
| Animations | `AnimatedContainer`, `AnimatedScale`, `AnimationController` + `AnimatedBuilder` |
| Backdrop blur | `BackdropFilter(filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18))` |

**No global stylesheet.** Every widget is self-contained with inline `BoxDecoration`. The closest to a "global style" is `AppTheme`, which sets defaults for Material components.

---

## 7. Asset Management

- **No `assets/` directory** is declared in `pubspec.yaml` — there are no bundled image or SVG assets.
- All icons are `CustomPainter` (drawn in code).
- App icons live in `ios/Runner/Assets.xcassets/` and `android/app/src/main/res/` (platform-native, not Flutter assets).
- Web icons in `web/icons/` (PWA manifest).
- **Adding image assets:** declare in `pubspec.yaml` under `flutter.assets:`, then reference with `Image.asset('assets/...')`.
- **Google Fonts** are loaded via the `google_fonts` package (network/cache, no font files bundled).

---

## 8. Project Structure

```
lib/
├── core/
│   ├── theme/
│   │   ├── app_colors.dart      ← all color tokens
│   │   ├── app_typography.dart  ← all text styles
│   │   ├── app_spacing.dart     ← spacing + radius tokens
│   │   └── app_theme.dart       ← ThemeData builder (light + dark)
│   ├── widgets/                 ← shared component library
│   │   ├── owl_button.dart      ← primary CTA button
│   │   ├── primary_card.dart    ← PrimaryCard + SurfaceCard
│   │   ├── ck_icons.dart        ← 20-icon custom set
│   │   ├── chapter_glyph.dart   ← 9 DSA topic glyphs
│   │   ├── skill_tree_node.dart ← skill tree circle node
│   │   ├── progress_bar.dart    ← animated progress bar
│   │   ├── ck_chip.dart         ← pill chip
│   │   ├── section_header.dart  ← divider with label
│   │   ├── glass_bar.dart       ← frosted glass app bar
│   │   ├── code_dust.dart       ← particle decoration
│   │   └── xp_toast.dart        ← XP gain toast
│   └── services/
│       └── api_service.dart     ← API integration seam (currently mocked)
├── features/
│   ├── home/                    ← skill tree + "continue learning" card
│   ├── lesson/                  ← concept explanation + AI chat + quiz
│   ├── code_editor/             ← smart autofill editor + execution
│   ├── practice/                ← problem list by category/difficulty
│   ├── leaderboard/             ← weekly XP ranking
│   ├── profile/                 ← settings, stats, logout
│   ├── onboarding/              ← 4-step preference flow
│   └── unit/                    ← unit detail / problem list
├── models/                      ← Category, Problem, UserProfile
├── providers/
│   └── app_providers.dart       ← Riverpod providers
├── router/
│   └── app_router.dart          ← GoRouter config
└── main.dart
```

---

## 9. Figma → Flutter Translation Rules

### Colors
- Figma hex → `AppColors.*` constant (match exactly or use the closest semantic token)
- Opacity in Figma → `color.withValues(alpha: 0.XX)` in Flutter
- Figma "Primary" → `AppColors.primary`
- Figma "Surface" → `scheme.surface`

### Typography
- Figma "Space Grotesk Bold 32" → `AppTypography.display`
- Figma "Inter SemiBold 13" → `AppTypography.label`
- Figma "JetBrains Mono" text → `AppTypography.codeBody`
- Never set `fontFamily` directly — extend the `AppTypography` getters

### Spacing
- Snap all Figma spacing to the nearest multiple of 4
- Map to `AppSpacing.*` constant; use `SizedBox` or `Padding`

### Components
- Figma "Primary Button" → `OwlButton(...)`
- Figma "Blue gradient card" → `PrimaryCard(...)`
- Figma "Card with border" → `SurfaceCard(...)`
- Figma "Pill chip / badge" → `CkChip(...)`
- Figma icons → `CkIcon.*()` if it exists; otherwise add a new `_IconKind`
- Figma "──── LABEL ────" → `SectionHeader(label: '...')`

### Shadows
- Figma single shadow → two `BoxShadow` layers: close (low blur, lower alpha) + diffuse (high blur, higher alpha)
- Shadow color → always based on the background's dark counterpart (e.g., `AppColors.primaryDark` for blue elements)

### Animations
- Figma "Hover" state → `GestureDetector` + `AnimatedScale(0.97)` with 120ms `easeOutCubic`
- Figma "Loading" state → `CircularProgressIndicator(strokeWidth: 2.5)`
- Figma "Pulsing ring" → `AnimationController` + `AnimatedBuilder`, expand ring with decreasing opacity

### Dark mode
- Figma dark frame → check `Theme.of(context).brightness == Brightness.dark`; swap `AppColors.dark*` tokens accordingly
- Always implement both light and dark variants when adding new screens
