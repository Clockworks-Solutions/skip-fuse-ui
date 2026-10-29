// Copyright 2026 Skip
// SPDX-License-Identifier: MPL-2.0
import Foundation
import XCTest
import SkipBridge
import SkipAndroidBridge
import SkipSwiftUISamples

#if SKIP
import androidx.compose.ui.input.InputMode
import androidx.compose.ui.input.InputModeManager
import androidx.compose.ui.platform.LocalInputModeManager
import androidx.compose.ui.test.assertIsFocused
import androidx.compose.ui.test.assertIsNotFocused
import androidx.compose.ui.test.assertTextEquals
import androidx.compose.ui.test.junit4.createComposeRule
import androidx.compose.ui.test.onNodeWithTag
import androidx.compose.ui.test.performClick
import androidx.compose.ui.test.requestFocus
#endif

/// Compose UI tests for the `isPresented` and `isFocused` environment values read by native
/// (Skip Fuse) views through the bridge.
final class FuseEnvironmentValuesTests: XCTestCase {
    // SKIP INSERT: @get:org.junit.Rule val composeRule = createComposeRule()

    /// Whether bridged main-actor calls can run on this host (see `prepareJVMHostedTesting`).
    var mainActorRelaxed = true

    override func setUp() {
        #if SKIP
        // Same bootstrap as `FuseComposeUITests`
        composeRule.runOnUiThread {
            try! loadPeerLibrary(packageName: "skip-fuse-ui", moduleName: "SkipSwiftUISamples")
            let context = ProcessInfo.processInfo.androidContext
            try! AndroidBridgeBootstrap.initAndroidBridge(filesDir: context.getFilesDir().getAbsolutePath(), cacheDir: context.getCacheDir().getAbsolutePath())
        }
        mainActorRelaxed = SkipSwiftUITestSupport.prepareJVMHostedTesting()
        #endif
    }

    private func requireBridgedMainActor() throws {
        if !mainActorRelaxed {
            throw XCTSkip("host Swift runtime lacks swift_task_checkIsolated_hook; bridged main-actor calls would trap")
        }
    }

    func testIsPresentedInSheet() throws {
        #if !SKIP
        throw XCTSkip("Compose UI testing is Android-only")
        #else
        try requireBridgedMainActor()
        composeRule.setContent {
            SheetPresentedTestFixture().Compose()
        }
        composeRule.waitForIdle()
        composeRule.onNodeWithTag("presenter").assertTextEquals("presented: false")

        composeRule.onNodeWithTag("show-sheet").performClick()
        composeRule.waitForIdle()
        composeRule.onNodeWithTag("sheet").assertTextEquals("presented: true")
        composeRule.onNodeWithTag("presenter").assertTextEquals("presented: false")
        #endif
    }

    func testIsPresentedInPushedDestination() throws {
        #if !SKIP
        throw XCTSkip("Compose UI testing is Android-only")
        #else
        try requireBridgedMainActor()
        composeRule.setContent {
            NavigationPresentedTestFixture().Compose()
        }
        composeRule.waitForIdle()
        composeRule.onNodeWithTag("stack-root").assertTextEquals("presented: false")

        composeRule.onNodeWithTag("push-link").performClick()
        composeRule.waitForIdle()
        composeRule.onNodeWithTag("destination").assertTextEquals("presented: true")
        #endif
    }

    func testFocusableUpdatesIsFocusedInKeyboardMode() throws {
        #if !SKIP
        throw XCTSkip("Compose UI testing is Android-only")
        #else
        try requireBridgedMainActor()
        var inputModeManager: InputModeManager? = nil
        composeRule.setContent {
            inputModeManager = LocalInputModeManager.current
            FocusableTestFixture().Compose()
        }
        composeRule.waitForIdle()
        composeRule.onNodeWithTag("focusable-reader").assertTextEquals("focused: false")

        // Like iOS, `.focusable()` views only take focus during keyboard navigation
        composeRule.runOnIdle { inputModeManager?.requestInputMode(InputMode.Keyboard) }
        composeRule.onNodeWithTag("focusable").requestFocus()
        composeRule.waitForIdle()
        composeRule.onNodeWithTag("focusable-reader").assertTextEquals("focused: true")
        composeRule.onNodeWithTag("sibling-reader").assertTextEquals("focused: false")
        composeRule.onNodeWithTag("unfocusable-reader").assertTextEquals("focused: false")
        #endif
    }

    func testFocusableIsNotFocusableInTouchMode() throws {
        #if !SKIP
        throw XCTSkip("Compose UI testing is Android-only")
        #else
        try requireBridgedMainActor()
        composeRule.setContent {
            FocusableTestFixture().Compose()
        }
        composeRule.waitForIdle()

        composeRule.onNodeWithTag("focusable").requestFocus()
        composeRule.waitForIdle()
        composeRule.onNodeWithTag("focusable-reader").assertTextEquals("focused: false")
        #endif
    }

    /// Regression check for skiptools/skip-ui#552 through the bridge.
    func testFocusStateFalseClearsTextFieldFocus() throws {
        #if !SKIP
        throw XCTSkip("Compose UI testing is Android-only")
        #else
        try requireBridgedMainActor()
        composeRule.setContent {
            FocusStateTestFixture().Compose()
        }
        composeRule.waitForIdle()

        composeRule.onNodeWithTag("plain-focus").performClick()
        composeRule.waitForIdle()
        composeRule.onNodeWithTag("plain-field").assertIsFocused()

        composeRule.onNodeWithTag("plain-unfocus").performClick()
        composeRule.waitForIdle()
        composeRule.onNodeWithTag("plain-field").assertIsNotFocused()
        #endif
    }

    func testFocusStateNilClearsFocusAndContainerIgnoresFocusedDescendant() throws {
        #if !SKIP
        throw XCTSkip("Compose UI testing is Android-only")
        #else
        try requireBridgedMainActor()
        composeRule.setContent {
            FocusStateTestFixture().Compose()
        }
        composeRule.waitForIdle()

        composeRule.onNodeWithTag("container-focus").performClick()
        composeRule.waitForIdle()
        composeRule.onNodeWithTag("container-field").assertIsFocused()
        // `isFocused` reflects the focusable view itself, as on iOS
        composeRule.onNodeWithTag("container-reader").assertTextEquals("focused: false")

        composeRule.onNodeWithTag("container-unfocus").performClick()
        composeRule.waitForIdle()
        composeRule.onNodeWithTag("container-field").assertIsNotFocused()
        #endif
    }
}
