//
//  CryptoAppUITestsLaunchTests.swift
//  CryptoAppUITests
//
//  Created by Micah Njeru on 30/11/2025.
//

import XCTest

final class CryptoAppUITestsLaunchTests: XCTestCase {

    override class var runsForEachTargetApplicationUIConfiguration: Bool { true }

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    @MainActor
    func testLaunch() throws {
        // Purpose: Verify the app can launch and capture a baseline screenshot
        let app = XCUIApplication()
        app.launch()

        // Basic check: at least one window exists
        XCTAssertTrue(app.windows.element(boundBy: 0).exists, "Expected the main window to exist after launch")

        // Take and keep a screenshot for diagnostics
        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = "Launch Screen"
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
