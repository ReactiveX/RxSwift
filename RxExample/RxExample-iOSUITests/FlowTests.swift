//
//  FlowTests.swift
//  RxExample
//
//  Created by Krunoslav Zaher on 8/20/16.
//  Copyright © 2016 Krunoslav Zaher. All rights reserved.
//

import XCTest

class FlowTests : XCTestCase {
    var app: XCUIApplication!
    override func setUp() {
        super.setUp()

        continueAfterFailure = false
        self.app = XCUIApplication()
        self.app.launchEnvironment = ["isUITest": ""]
        self.app.launch()
    }
}

extension FlowTests {
    func testGitHubSignUp() {
        app.tables.allElementsBoundByIndex[0].cells.allElementsBoundByIndex[3].tap()
        let username = app.textFields.allElementsBoundByIndex[0]
        let password = app.secureTextFields.allElementsBoundByIndex[0]
        let repeatedPassword = app.secureTextFields.allElementsBoundByIndex[1]

        username.tap()
        username.typeText("rxrevolution")

        password.tap()
        password.typeText("mypassword")

        repeatedPassword.tap()
        repeatedPassword.typeText("mypassword")

        app.windows.allElementsBoundByIndex[0].coordinate(withNormalizedOffset: CGVector(dx: 14.50, dy: 80.00)).tap()
        app.buttons["Sign up"].tap()

        waitForElementToAppear(app.alerts.element(boundBy: 0))

        app.alerts.allElementsBoundByIndex[0].buttons.allElementsBoundByIndex[0].tap()

        goBack()
    }

    func testSearchWikipedia() {
        app.tables.allElementsBoundByIndex[0].cells.allElementsBoundByIndex[12].tap()

        let searchField = app.tables.children(matching: .searchField).element

        searchField.tap()

        searchField.typeSlow(text: "banana")
        searchField.clearText()
        searchField.typeSlow(text: "Yosemite")
        searchField.clearText()

        goBack()
    }

    func testMasterDetail() {
        app.tables.allElementsBoundByIndex[0].cells.allElementsBoundByIndex[10].tap()
        waitForElementToAppear(app.tables.allElementsBoundByIndex[0].cells.element(boundBy: 5), timeout: 10.0)

        let editButton = app.navigationBars.buttons["Edit"]

        editButton.tap()

        func reorderButtonForIndex(_ index: Int) -> XCUIElement {
            return app.tables.cells.allElementsBoundByIndex[index].buttons.allElementsBoundByIndex.filter { element in
                element.label.hasPrefix("Reorder ")
            }.first!
        }

        reorderButtonForIndex(5).press(forDuration: 1.5, thenDragTo: reorderButtonForIndex(2))

        reorderButtonForIndex(7).press(forDuration: 1.5, thenDragTo: reorderButtonForIndex(4))

        reorderButtonForIndex(1).press(forDuration: 1.5, thenDragTo: reorderButtonForIndex(3))

        let doneButton = app.navigationBars.buttons["Done"]
        doneButton.tap()

        app.tables.allElementsBoundByIndex[0].cells.allElementsBoundByIndex[6].tap()

        goBack()
        goBack()
    }

    func testAnimatedPartialUpdates() {
        app.tables.allElementsBoundByIndex[0].cells.allElementsBoundByIndex[11].tap()

        let randomize = app.navigationBars.buttons["Randomize"]
        waitForElementToAppear(randomize)

        randomize.tap()
        randomize.tap()
        randomize.tap()
        randomize.tap()
        randomize.tap()
        randomize.tap()
        randomize.tap()
        randomize.tap()
        randomize.tap()

        goBack()
    }

    func testVisitEveryScreen() {
        let cells = app.tables.allElementsBoundByIndex[0].cells.allElementsBoundByIndex
        XCTAssertTrue(cells.count > 0)

        for i in 0 ..< cells.count {
            cells[i].tap()
            goBack()
        }
    }
}

extension FlowTests {
    func testControls() {
        for test in [
        _testDatePicker,
        _testBarButtonItemTap,
        _testButtonTap,
        _testSegmentedControl,
        _testUISwitch,
        _testUITextField,
        _testUITextView,
        _testSlider
            ] {
            goToControlsView()
            test()
            goBack()
        }
    }

    func goToControlsView() {
        let tableView = app.tables.element(boundBy: 0)

        waitForElementToAppear(tableView)

        tableView.cells.allElementsBoundByIndex[5].tap()
    }

    func checkDebugLabelValue(_ expected: String) {
        let textValue = app.staticTexts["debugLabel"].value as? String
        XCTAssertEqual(textValue, expected)
    }

    func _testDatePicker() {
        let picker = app.datePickers.allElementsBoundByIndex[0]
        picker.pickerWheels.element(boundBy: 0).coordinate(withNormalizedOffset: CGVector(dx: 0.49, dy: 0.65)).tap()
        picker.pickerWheels.element(boundBy: 1).coordinate(withNormalizedOffset: CGVector(dx: 0.35, dy: 0.64)).tap()
        picker.pickerWheels.element(boundBy: 2).coordinate(withNormalizedOffset: CGVector(dx: 0.46, dy: 0.64)).tap()

        wait(interval: 1.0)

        checkDebugLabelValue("UIDatePicker date 1970-01-02 01:01:00 +0000")
    }

    func _testBarButtonItemTap() {
        app.navigationBars.buttons["TapMe"].tap()
        checkDebugLabelValue("UIBarButtonItem Tapped")
    }

    func _testButtonTap() {
        app.scrollViews.buttons["TapMe"].tap()
        checkDebugLabelValue("UIButton Tapped")
    }

    func _testSegmentedControl() {
        let segmentedControl = app.scrollViews.segmentedControls.allElementsBoundByIndex[0]
        segmentedControl.buttons["Second"].tap()
        checkDebugLabelValue("UISegmentedControl value 1")
        segmentedControl.buttons["First"].tap()
        checkDebugLabelValue("UISegmentedControl value 0")
    }

    func _testUISwitch() {
        let switchControl = app.switches.allElementsBoundByIndex[0]
        switchControl.tap()
        checkDebugLabelValue("UISwitch value false")
        switchControl.tap()
        checkDebugLabelValue("UISwitch value true")
    }

    func _testUITextField() {
        let textField = app.textFields.allElementsBoundByIndex[0]
        textField.tap()
        textField.typeText("f")
        checkDebugLabelValue("UITextField text f")
    }

    func _testUITextView() {
        let textView = app.textViews.allElementsBoundByIndex[0]
        textView.tap()
        textView.typeText("f")
        checkDebugLabelValue("UITextView text f")
    }

    func _testSlider() {
        let slider = app.sliders.allElementsBoundByIndex[0]
        slider.adjust(toNormalizedSliderPosition: 0)
        checkDebugLabelValue("UISlider value 0.0")
    }
}

extension FlowTests {

    func goBack() {
        wait(interval: 1.0)
        let window = app.windows.element(boundBy: 0)
        window.coordinate(withNormalizedOffset: .zero).withOffset(CGVector(dx: 40, dy: 30)).tap()
        wait(interval: 1.5)
    }

    func waitForElementToAppear(_ element: XCUIElement, timeout: TimeInterval = 2,  file: String = #file, line: UInt = #line) {
        let existsPredicate = NSPredicate(format: "exists == true")

        expectation(for: existsPredicate,
                    evaluatedWith: element,
                    handler: nil)

        waitForExpectations(timeout: timeout) { (error) -> Void in
            if (error != nil) {
                let message = "Failed to find \(element) after \(timeout) seconds."
                self.recordFailure(withDescription: message, inFile: file, atLine: line, expected: true)
            }
        }
    }

    func wait(interval: TimeInterval) {
        RunLoop.current.run(until: Date().addingTimeInterval(interval))
    }

}

extension XCUIElement {
    func clearText() {
        let backspace = "\u{8}"
        let backspaces = Array(((self.value as? String) ?? "").characters).map { _ in backspace }
        self.typeText(backspaces.joined(separator: ""))
    }

    func typeSlow(text: String) {
        for i in text.characters {
            self.typeText(String(i))
        }
    }
}
