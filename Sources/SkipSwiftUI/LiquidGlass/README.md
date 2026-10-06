# Liquid Glass — Skip Fuse layer

Clockworks fork additions that expose the Liquid Glass support in the
[Clockworks SkipUI fork](https://github.com/Clockworks-Solutions/skip-ui/tree/liquid-glass) to Skip Fuse apps. SkipUI
renders the glass on Android; this layer is only the SwiftUI-shaped public API that natively compiled Swift calls, and
the bridge calls that carry each value across to SkipUI.

Forked from [skiptools/skip-fuse-ui](https://github.com/skiptools/skip-fuse-ui), which the `upstream` git remote
points at.

## What a Fuse app gets without any code

SkipFuseUI's `TabView`, `NavigationStack`, and `.toolbar` all render through SkipUI, so on Android a Fuse app picks up
the glass chrome as soon as it depends on this fork:

- The `TabView` bottom bar is the floating Liquid Glass tab bar, with the sliding selection pill, drag-to-select, and
  content that scrolls under and refracts through the bar.
- The navigation back button, top bar items, and bottom toolbar items render as glass capsules, as on iOS 26: every
  system placement (`.automatic`, `.cancellationAction`, `.confirmationAction`, `.bottomBar`, …) is on glass whatever
  the button style, `.confirmationAction` sits last on the trailing side, and `.principal` content is never on glass.
  `ToolbarSpacer` groups items into separate capsules; oversized images are scaled to fit.
- Glass refracts the view layered behind it by `background`, `overlay`, `ZStack` and `safeAreaInset`, and turns light
  or dark to suit it.
- `List` and `ScrollView` add the bar's height after their content, so the last row can be scrolled clear of the bar.
- Tab `tint`, `toolbarBackground(_:for: .tabBar)`, `toolbar(.hidden, for: .tabBar)`, `Tab.disabled(_:)`, and
  `Tab.hidden(_:)` apply to the glass bar as they do to the Material bar.

Whether glass renders at all is decided per device: see [Rendering tiers](#rendering-tiers).

## Public API

| API | Where | What it does on Android |
| --- | --- | --- |
| `LiquidGlass` | `LiquidGlass.swift` | `adaptive` (default), `disabled`, `forced`, `forcedOptimized`. |
| `EnvironmentValues.liquidGlass` | `LiquidGlass.swift` | Switches glass on or off for a subtree. Readable with `@Environment(\.liquidGlass)`. |
| `tabBarMinimizeBehavior(_:)` | `Containers/TabView.swift` | `.onScrollDown` / `.onScrollUp` shrink the glass bar as content scrolls. `.automatic` and `.never` keep it full size. |
| `TabContent.badge(_:)` | `Containers/TabView.swift` | Draws a badge on the tab's item, in the glass bar and the Material bar. `0` or `nil` removes it. |
| `GlassButtonStyle` / `.glass` | `Controls/Button.swift` | The label on a glass capsule; `.bordered` when glass is off. |
| `GlassProminentButtonStyle` / `.glassProminent` | `Controls/Button.swift` | The label on a tinted glass capsule; `.borderedProminent` when glass is off. |
| `Glass`, `.regular`, `tint(_:)`, `interactive(_:)` | `Graphics/Glass.swift` | The glass configuration for `glassEffect`. |
| `glassEffect(_:in:isEnabled:)` | `Graphics/Glass.swift` | Draws glass behind a view in any `Shape`; a `surfaceContainerHigh` or tint fill when glass is off. |

### `liquidGlass`

```swift
import SkipFuseUI

HomeScreen()
    .environment(\.liquidGlass, .disabled)   // Material 3 everywhere below

struct DebugView: View {
    @Environment(\.liquidGlass) var liquidGlass

    var body: some View {
        Text(verbatim: "\(liquidGlass)")
    }
}
```

Import `SkipFuseUI` rather than `SwiftUI` in a file that names `liquidGlass` or `LiquidGlass`. On Android both imports
resolve to this module, but on Apple platforms `import SwiftUI` is Apple's SwiftUI, which has no such value;
`SkipFuseUI` re-exports `LiquidGlass` and adds `EnvironmentValues.liquidGlass` there as a stored value with no effect,
since iOS renders Liquid Glass natively. Shared code therefore compiles unchanged on both platforms.

### Tab bar

```swift
TabView(selection: $selection) {
    Tab("Pickup", systemImage: "fork.knife", value: .pickup) { PickupScreen() }
        .badge(3)
    Tab("Reserve", systemImage: "door.left.hand.open", value: .reserve) { ReserveScreen() }
        .badge("New")
        .disabled(isClosed)
}
.tint(.green)
.tabBarMinimizeBehavior(.onScrollDown)
```

`tabBarMinimizeBehavior(_:)` is iOS 26+ on Apple platforms; wrap it in `if #available(iOS 26.0, *)` when the app
supports earlier versions. On Android the check is always true.

### Glass buttons and surfaces

```swift
Button("Edit") { edit() }
    .buttonStyle(.glass)

Button("Done") { finish() }
    .buttonStyle(.glassProminent)
    .tint(.orange)

Image(systemName: "gearshape")
    .padding(12)
    .glassEffect(.regular.tint(.green).interactive(), in: Circle())
```

In a toolbar, adjacent `.glass` items share one capsule and a `.glassProminent` item is a capsule of its own, as on
iOS 26.

## Rendering tiers

SkipUI fixes how much glass a device can afford before the first frame, from the level
[Droid Dex](https://github.com/grofers/droid-dex) measured on an earlier launch (or a memory and core estimate on the
first): `FULL` (lens with chromatic aberration), `REDUCED` (blur without refraction). Glass follows the system light or dark theme on every tier for now, or `NATIVE`
(Material 3). `liquidGlass` picks how that level is used:

| Value | High-end | Mid-range | Low-end / unmeasured |
| --- | --- | --- | --- |
| `.adaptive` | `FULL` | `REDUCED` | `NATIVE` |
| `.forcedOptimized` | `FULL` | `REDUCED` | `REDUCED` |
| `.forced` | `FULL` | `FULL` | `FULL` |
| `.disabled` | `NATIVE` | `NATIVE` | `NATIVE` |

`.forced` and `.disabled` never read the level. SkipUI's `Sources/SkipUI/Skip/LiquidGlass/README.md` shows how to set
the stored level to test a tier.

## Bridging

Each API crosses the bridge as plain values, and SkipUI rebuilds its own types from them:

| SkipFuseUI | Crosses as | SkipUI entry point |
| --- | --- | --- |
| `.environment(\.liquidGlass, …)` / `@Environment(\.liquidGlass)` | the raw `Int`, as the builtin key `"liquidGlass"` | `builtinBridged(key:)` / `setBuiltinBridged(key:value:)` → `liquidGlassBridged()` / `setLiquidGlassBridged(_:)` in `LiquidGlass.swift` |
| `tabBarMinimizeBehavior(_:)` | the behavior's identity, 1–4 | `View.tabBarMinimizeBehavior(bridgedBehavior:)` in `TabView+LiquidGlass.swift` |
| `TabContent.badge(_:)` | a bridged `Text?`; the `Int`, `String`, and key overloads are resolved to it first | `TabContent.tabBadge(bridgedLabel:)` in `TabView+LiquidGlass.swift` |
| `.buttonStyle(.glass)` / `.glassProminent` | the style identifier, 5 / 6 | `View.buttonStyle(bridgedStyle:)` in `Button.swift` |
| `glassEffect(_:in:isEnabled:)` | the tint as a `SkipUI.Color`, the interactive flag, the `Shape`, and the enabled flag | `View.glassEffect(bridgedTint:isInteractive:in:isEnabled:)` in `Glass+LiquidGlass.swift` |

The `"liquidGlass"` key and its raw values must match on both sides: `EnvironmentValues.builtin(key:bridgedValue:)`,
`bridgeBuiltin(key:value:)`, and the `keys` table in `Environment/EnvironmentValues.swift` here, and the two cases in
SkipUI's `Environment/EnvironmentValues.swift`.

## Upstream touch points

Upstream SkipFuseUI files are edited only where a stub has to become a real implementation, and each edit carries a
`// Liquid Glass:` marker naming where to look, so a sync with upstream shows conflicts exactly where the fork differs.

| Upstream file | What the marked lines do |
| --- | --- |
| `Environment/EnvironmentValues.swift` | Register `liquidGlass` as a builtin key and convert it in both directions. |
| `Containers/TabView.swift` | Bridge `tabBarMinimizeBehavior(_:)`, make `.onScrollDown` / `.onScrollUp` available, and bridge `Tab` badges. |
| `Controls/Button.swift` | Make `GlassButtonStyle` / `.glass` available and add `GlassProminentButtonStyle` / `.glassProminent`. |
| `Graphics/Glass.swift` | Give `Glass` its tint and interactive state, and bridge `glassEffect(_:in:isEnabled:)`. |
| `SkipFuseUI/SwiftUI.swift` | On Apple platforms, re-export `LiquidGlass` and add a no-op `EnvironmentValues.liquidGlass`. |

## Known issues

- **`glassEffect` shapes.** The lens effect only works on corner-based Compose shapes. `Capsule`, `Circle`,
  `Rectangle`, `RoundedRectangle`, and `UnevenRoundedRectangle` are mapped to one and keep the full effect. A `Circle`
  in a frame that isn't square draws as a capsule, and corners are always circular. Any other shape (a custom
  `Shape`, or one changed with `inset`, `offset`, `rotation`, and so on) renders as glass without the lens.
- **Changing `liquidGlass` at runtime resets navigation.** Switching between glass and Material swaps the navigation
  chrome, and a pushed screen is popped back to the tab's root.
- **Unframed resizable tab icons.** On the Material bar, a tab icon that is `Image(...).resizable()` with no `frame`
  makes the bar fill the screen and hides the tab content. Give tab icons a fixed frame, such as
  `.frame(width: 24, height: 24)`.

## Not supported yet

- `Glass.clear` and `Glass.identity`, `GlassEffectContainer`, `glassEffectID(_:in:)`, `glassEffectUnion(id:namespace:)`,
  and `glassEffectTransition(_:)` other than `.identity`.
- `tabViewBottomAccessory(content:)`, `TabRole.search` rendered as the separate search capsule, and `TabSection`.
- Apple's shipping `glassEffect(_:in:)` has no `isEnabled` parameter; this fork keeps the defaulted one inherited from
  upstream, so `isEnabled:` compiles only on Android.
