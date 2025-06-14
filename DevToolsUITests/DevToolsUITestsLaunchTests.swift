//
//  DevToolsUITestsLaunchTests.swift
//  DevToolsUITests
//
//  Created by Khanh Le on 9/6/25.
//

import XCTest

final class DevToolsUITestsLaunchTests: XCTestCase {

    override class var runsForEachTargetApplicationUIConfiguration: Bool {
        true
    }

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    @MainActor
    func testLaunch() throws {
        let app = XCUIApplication()
        app.launch()

        // Wait for the app to become stable before taking screenshot
        // This helps prevent accessibility loading issues
        let exists = app.wait(for: .runningForeground, timeout: 15.0)
        XCTAssertTrue(exists, "App should be running in foreground")
        
        // Wait for accessibility to be fully available
        // This is particularly important for Light mode which seems to have timing issues
        let accessibilityTimeout: TimeInterval = 20.0
        let startTime = Date()
        
        while Date().timeIntervalSince(startTime) < accessibilityTimeout {
            // Try to access the app's main window to ensure accessibility is ready
            if app.windows.count > 0 && app.windows.firstMatch.exists {
                // Give a brief moment for any remaining UI setup
                Thread.sleep(forTimeInterval: 0.5)
                break
            }
            Thread.sleep(forTimeInterval: 0.1)
        }
        
        // Verify we have at least one window available
        XCTAssertTrue(app.windows.count > 0, "App should have at least one window")

        // Insert steps here to perform after app launch but before taking a screenshot,
        // such as logging into a test account or navigating somewhere in the app

        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = "Launch Screen"
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
