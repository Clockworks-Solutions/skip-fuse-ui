// Copyright 2025–2026 Skip
// SPDX-License-Identifier: MPL-2.0
#if !ROBOLECTRIC && canImport(CoreGraphics)
import CoreGraphics
#endif
import SkipUI

/// The configuration of a Liquid Glass surface, for `glassEffect(_:in:isEnabled:)`.
///
/// Rendered with Liquid Glass on Android wherever `EnvironmentValues.liquidGlass` allows it, and as a Material 3
/// surface otherwise.
///
/// ```swift
/// Text("Glass")
///     .padding()
///     .glassEffect(.regular.tint(.green).interactive(), in: .capsule)
/// ```
public struct Glass : Equatable, Sendable {
    /// The color the glass is tinted with, if any.
    let tintColor: Color? // Liquid Glass: see LiquidGlass/README.md
    /// Whether the glass reacts to touch.
    let isInteractive: Bool // Liquid Glass: see LiquidGlass/README.md

    init(tintColor: Color? = nil, isInteractive: Bool = false) {
        self.tintColor = tintColor
        self.isInteractive = isInteractive
    }

    /// The standard glass: untinted, and not reacting to touch.
    public static var regular: Glass {
        return Glass()
    }

    /// Returns a copy of this glass tinted with `color`, or untinted when `color` is `nil`.
    public func tint(_ color: Color?) -> Glass {
        return Glass(tintColor: color, isInteractive: isInteractive)
    }

    /// Returns a copy of this glass that reacts to touch with a highlight that follows the finger when `isEnabled`.
    public func interactive(_ isEnabled: Bool = true) -> Glass {
        return Glass(tintColor: tintColor, isInteractive: isEnabled)
    }
}

@MainActor @preconcurrency public struct GlassEffectContainer<Content> : View, Sendable where Content : View {
    @available(*, unavailable)
    public init(spacing: CGFloat? = nil, @ViewBuilder content: () -> Content) {
    }

    public var body: some View {
        EmptyView()
    }
}

public struct GlassEffectTransition : Sendable {
    @available(*, unavailable)
    public static var matchedGeometry: GlassEffectTransition {
        return GlassEffectTransition()
    }

    @available(*, unavailable)
    public static func matchedGeometry(properties: MatchedGeometryProperties = .frame, anchor: UnitPoint = .center) -> GlassEffectTransition {
        return GlassEffectTransition()
    }

    public static var identity: GlassEffectTransition {
        return GlassEffectTransition()
    }
}

extension View {
    /// Draws `glass` behind this view, in `shape`.
    ///
    /// On Android this is Liquid Glass wherever `EnvironmentValues.liquidGlass` allows it, sampling what is drawn
    /// behind the view; otherwise `shape` is filled with the Material 3 `surfaceContainerHigh` color, or with the
    /// glass tint.
    ///
    /// - Parameters:
    ///   - glass: The glass configuration: its tint, and whether it reacts to touch.
    ///   - shape: The shape of the glass. Defaults to a capsule.
    ///   - isEnabled: Whether the effect is applied; `false` leaves the view unchanged.
    nonisolated public func glassEffect(_ glass: Glass = .regular, in shape: some Shape = .capsule, isEnabled: Bool = true) -> some View {
        return ModifierView(target: self) { // Liquid Glass: see SkipUI Glass+LiquidGlass.swift
            $0.Java_viewOrEmpty.glassEffect(bridgedTint: glass.tintColor?.Java_view as? SkipUI.Color, isInteractive: glass.isInteractive, in: shape.Java_shape, isEnabled: isEnabled)
        }
    }

    @MainActor @preconcurrency public func glassEffectTransition(_ transition: GlassEffectTransition, isEnabled: Bool = true) -> some View {
        // We only support .identity
        return self
    }

    @available(*, unavailable)
    @MainActor @preconcurrency public func glassEffectUnion(id: (some Hashable & Sendable)?, namespace: Namespace.ID) -> some View {
        stubView()
    }

    @available(*, unavailable)
    nonisolated public func glassEffectID(_ id: (some Hashable & Sendable)?, in namespace: Namespace.ID) -> some View {
        stubView()
    }
}
