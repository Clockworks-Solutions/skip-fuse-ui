// Copyright 2026 Skip
// SPDX-License-Identifier: MPL-2.0
import SkipFuse
import SkipSwiftUI

// Native sample views for the `isPresented` / `isFocused` environment value tests in
// `FuseEnvironmentValuesTests`.

/// Displays the `isPresented` environment value.
struct PresentedReader: View {
    let tag: String
    @Environment(\.isPresented) var isPresented

    var body: some View {
        Text("presented: \(isPresented ? "true" : "false")")
            .accessibilityIdentifier(tag)
    }
}

/// Displays the `isFocused` environment value.
struct FocusedReader: View {
    let tag: String
    @Environment(\.isFocused) var isFocused

    var body: some View {
        Text("focused: \(isFocused ? "true" : "false")")
            .accessibilityIdentifier(tag)
    }
}

/// Sample: a presenter and a sheet that both read `isPresented`.
public struct SheetPresentedTestFixture: View {
    @State var isShowingSheet = false

    public init() {
    }

    public var body: some View {
        VStack {
            PresentedReader(tag: "presenter")
            Button("show") { isShowingSheet = true }
                .accessibilityIdentifier("show-sheet")
        }
        .sheet(isPresented: $isShowingSheet) {
            VStack {
                PresentedReader(tag: "sheet")
                Button("close") { isShowingSheet = false }
                    .accessibilityIdentifier("close-sheet")
            }
        }
    }
}

/// Sample: a navigation stack root and a pushed destination that both read `isPresented`.
public struct NavigationPresentedTestFixture: View {
    public init() {
    }

    public var body: some View {
        NavigationStack {
            VStack {
                PresentedReader(tag: "stack-root")
                NavigationLink("push") {
                    PresentedReader(tag: "destination")
                }
                .accessibilityIdentifier("push-link")
            }
        }
    }
}

/// Sample: two `.focusable()` views reading `isFocused`, and a view with no focusable ancestor.
public struct FocusableTestFixture: View {
    public init() {
    }

    public var body: some View {
        VStack {
            VStack {
                Text("Focus target")
                FocusedReader(tag: "focusable-reader")
            }
            .focusable()
            .accessibilityIdentifier("focusable")
            FocusedReader(tag: "sibling-reader")
                .focusable()
            FocusedReader(tag: "unfocusable-reader")
        }
    }
}

public enum FocusStateTestField: Hashable {
    case field
}

/// Sample: text fields bound to `@FocusState`, plain and inside a `.focusable()` container.
public struct FocusStateTestFixture: View {
    @FocusState var isPlainFocused: Bool
    @FocusState var containerField: FocusStateTestField?
    @State var plainText = ""
    @State var containerText = ""

    public init() {
    }

    public var body: some View {
        VStack {
            Button("focus") { isPlainFocused = true }
                .accessibilityIdentifier("plain-focus")
            Button("unfocus") { isPlainFocused = false }
                .accessibilityIdentifier("plain-unfocus")
            TextField("Plain", text: $plainText)
                .focused($isPlainFocused)
                .accessibilityIdentifier("plain-field")

            Button("focus") { containerField = .field }
                .accessibilityIdentifier("container-focus")
            Button("unfocus") { containerField = nil }
                .accessibilityIdentifier("container-unfocus")
            VStack {
                FocusedReader(tag: "container-reader")
                TextField("In container", text: $containerText)
                    .focused($containerField, equals: .field)
                    .accessibilityIdentifier("container-field")
            }
            .focusable()
        }
    }
}
