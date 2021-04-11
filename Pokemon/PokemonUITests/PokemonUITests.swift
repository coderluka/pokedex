//
//  PokemonUITests.swift
//  PokemonUITests
//
//  Created by Luka Dimitrijevic on 09.04.21.
//

import XCTest

class PokemonUITests: XCTestCase {

    private let app = XCUIApplication() // create app instance
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        
        // take a screenshot after test
        saveScreenshot(name: "Teardown")
        
        // close the app
        app.terminate()
    }

    func testMisc() throws {
        // UI tests must launch the application that they test.
        app.launch()

        // Use recording to get started writing UI tests.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        
        openNotificationCentre()
        openTodayView()
        
        XCUIDevice.shared.press(XCUIDevice.Button.home)
        app.terminate()
    }
    
    func testLogin() {
        app.launch()
        
        // find mail text field
        let mailTxt = app.textFields["mail"]
        // find pass text field
        let passTxt = app.secureTextFields["password"]
        // find login button
        let loginBtn = app.buttons["login"]
        
        // open keyboard by tapping the element until it appears (is ready)
        mailTxt.tap()
        
        // send text to the located fields
        mailTxt.typeText("Ash@Ketchup.com")
        
        passTxt.tap()
        passTxt.typeText("1234567890")
        
        // dismiss the keyboard
        app.tap()
        // tap the button
        loginBtn.tap()
        
        saveScreenshot(name: "Login")
    }

    func testLaunchPerformance() throws {
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, *) {
            // This measures how long it takes to launch your application.
            measure(metrics: [XCTApplicationLaunchMetric()]) {
                app.launch()
            }
        }
    }
}

extension PokemonUITests {
    func saveScreenshot(name: String) {
        app.launchArguments = ["enable-screenshot-data"]
        
        // take a screenshot after test
        let screenshot = XCUIScreen.main.screenshot()
        let fullScreenshotAttachment = XCTAttachment(uniformTypeIdentifier: "public.png", name: "Screenshot-\(name)-\(UIDevice.current.name).png", payload: screenshot.pngRepresentation, userInfo: nil)
        fullScreenshotAttachment.lifetime = .keepAlways
        add(fullScreenshotAttachment)
    }
}

extension PokemonUITests {
    func openNotificationCentre() {
        // Open Notification Center
        let bottomPoint = app.coordinate(withNormalizedOffset: CGVector(dx: 0, dy: 2))
        app.coordinate(withNormalizedOffset: CGVector(dx: 0, dy: 0)).press(forDuration: 0.1, thenDragTo: bottomPoint)
    }
    
    func openTodayView() {
        // Open Today View
        let springboard = XCUIApplication(bundleIdentifier: "com.apple.springboard")
        springboard.scrollViews.firstMatch.swipeRight()
    }
}
