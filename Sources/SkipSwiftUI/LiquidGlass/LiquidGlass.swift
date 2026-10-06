//
//  LiquidGlass.swift
//  skip-fuse-ui
//
//  Liquid Glass (Clockworks fork): the switch that picks how glass renders on Android.
//

import SkipUI

/// Whether glass components render as Liquid Glass on Android: the `TabView` bar, toolbars, `.glass` and
/// `.glassProminent` buttons and `glassEffect`, or else their Material 3 counterparts. No effect on Apple platforms.
///
/// ```swift
/// ContentView()
///     .environment(\.liquidGlass, .disabled)
/// ```
public enum LiquidGlass : Int, Hashable, Sendable {
    /// The default: full glass on high-end devices, glass without refraction on mid-range ones, Material on
    /// low-end ones. Decided once per launch, so the first frame is already right.
    case adaptive = 0 // For bridging

    /// Always Material; nothing is measured.
    case disabled = 1 // For bridging

    /// Always full glass; nothing is measured.
    case forced = 2 // For bridging

    /// Always glass: full on high-end devices, without refraction elsewhere.
    case forcedOptimized = 3 // For bridging
}

// MARK: - EnvironmentValues: LiquidGlass

extension EnvironmentValues {
    /// How glass in this subtree renders; ``LiquidGlass/adaptive`` by default. Bridged under the `"liquidGlass"` key.
    public var liquidGlass: LiquidGlass {
        get { fatalError("Read via @Environment property wrapper") }
        set { fatalError("Set via .environment(_:_:) View modifier") }
    }
}
