//
//  Kamishibai_ExampleUITests.swift
//  Kamishibai_ExampleUITests
//
//  Created by Matsuo Keisuke on 8/22/17.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import XCTest
@testable import Kamishibai_Example

class Kamishibai_ExampleUITests: XCTestCase {

    var app: XCUIApplication!
        
    override func setUp() {
        super.setUp()
        
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        app = XCUIApplication()
        app.launch()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {

        let screenSize = UIScreen.main.bounds.size
        let screenCenter = CGPoint(x: screenSize.width / 2, y: screenSize.height / 2)

        // scene 1
        waitFor(element: app.otherElements["scene 1"])
        app.otherElements["focus"].tap(point: CGPoint(x: 0, y: 100))

        // scene 2
        waitFor(element: app.otherElements["scene 2"])
        app.buttons["Next"].tap()

        // scene 3
        waitFor(element: app.otherElements["scene 3"])
        app.otherElements["focus"].tap(point: screenCenter)

        // scene 4
        waitFor(element: app.otherElements["scene 4"])
        app.otherElements["focus"].tap(point: screenCenter)

        // scene 5 finish immediately

        // scene 6
        waitFor(element: app.otherElements["scene 6"])
        waitFor(element: app.alerts["Congraturations!"])
    }
}

extension XCUIElement {
    func tap(point: CGPoint) {
        let screenSize = UIScreen.main.bounds.size
        let vector = CGVector(dx: point.x / screenSize.width, dy: point.y / screenSize.height)
        self.coordinate(withNormalizedOffset: vector).tap()
    }
}

extension XCTestCase {
    func waitFor(element: Any, error: ((Error?) -> Void)? = nil) {
        let existsPredicate = NSPredicate(format: "exists == true")
        expectation(for: existsPredicate, evaluatedWith: element, handler: nil)
        waitForExpectations(timeout: 10, handler: error)
    }
}
