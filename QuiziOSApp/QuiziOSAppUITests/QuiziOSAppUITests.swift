//
//  QuiziOSAppUITests.swift
//  QuiziOSAppUITests
//
//  Created by Matt on 29/10/2025.
//

import XCTest

final class QuiziOSAppUITests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    func testCapitalQuestionDisplaysAnswer() {
        let app = launchApp(
            responses: [.success(text: "The capital of Belgium is Brussels.")]
        )

        app.launch()
        ask("What is the capital of Belgium?", in: app)

        assertMessageExists("What is the capital of Belgium?", in: app)
        assertMessageExists("The capital of Belgium is Brussels.", in: app)
    }

    func testFlagQuestionDisplaysAnswer() {
        let app = launchApp(
            responses: [.success(text: "The flag of Belgium is 🇧🇪.")]
        )

        app.launch()
        ask("Show me the flag of Belgium", in: app)

        assertMessageExists("Show me the flag of Belgium", in: app)
        assertMessageExists("The flag of Belgium is 🇧🇪.", in: app)
    }

    func testISOQuestionDisplaysAnswer() {
        let app = launchApp(
            responses: [.success(text: "The ISO alpha-2 code for Belgium is BE.")]
        )

        app.launch()
        ask("What is the ISO code for Belgium?", in: app)

        assertMessageExists("What is the ISO code for Belgium?", in: app)
        assertMessageExists("The ISO alpha-2 code for Belgium is BE.", in: app)
    }

    func testPrefixQuestionDisplaysAnswer() {
        let app = launchApp(
            responses: [.success(text: "Countries that start with BE: Belgium, Belize.")]
        )

        app.launch()
        ask("Which countries start with Be?", in: app)

        assertMessageExists("Which countries start with Be?", in: app)
        assertMessageExists("Countries that start with BE: Belgium, Belize.", in: app)
    }

    func testRetryButtonReplaysLastQuestionAfterFailure() {
        let app = launchApp(
            responses: [
                .failure,
                .success(text: "The capital of Belgium is Brussels.")
            ]
        )

        app.launch()
        ask("Capital of Belgium", in: app)

        let alert = app.alerts["Connection Issue"]
        XCTAssertTrue(alert.waitForExistence(timeout: 2))
        XCTAssertTrue(alert.staticTexts["I couldn't fetch country information. Please try again."].exists)
        alert.buttons["Cancel"].tap()
        XCTAssertFalse(alert.waitForExistence(timeout: 1))

        let retryButton = app.buttons["retry-button"]
      
        XCTAssertTrue(retryButton.waitForExistence(timeout: 1))
        XCTAssertTrue(retryButton.isEnabled)
        retryButton.tap()

        assertMessageExists("Capital of Belgium", in: app)
        assertMessageExists("The capital of Belgium is Brussels.", in: app)
    }
}

// MARK: - Helpers

private extension QuiziOSAppUITests {
    func launchApp(responses: [StubResponse]) -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments.append("UITesting")

        let payload = StubConfiguration(responses: responses)
        let data = try! JSONEncoder().encode(payload)
        app.launchEnvironment["UITEST_RESPONSES"] = String(data: data, encoding: .utf8)

        return app
    }

    func ask(_ question: String, in app: XCUIApplication) {
        let textField = app.textFields["question-input"]
        XCTAssertTrue(textField.waitForExistence(timeout: 1))
        textField.tap()
        textField.typeText(question)
        app.buttons["submit"].firstMatch.tap()
    }

    func assertMessageExists(_ text: String, in app: XCUIApplication) {
        let element = app.staticTexts[text]
        XCTAssertTrue(element.waitForExistence(timeout: 2))
    }
}

private struct StubConfiguration: Encodable {
    let responses: [StubResponse]
}

private struct StubResponse: Encodable {
    enum Result: String, Encodable {
        case success
        case failure
    }

    let result: Result
    let text: String?
    let imageURL: String?

    static func success(text: String, imageURL: String? = nil) -> StubResponse {
        StubResponse(result: .success, text: text, imageURL: imageURL)
    }

    static var failure: StubResponse {
        StubResponse(result: .failure, text: nil, imageURL: nil)
    }
}
