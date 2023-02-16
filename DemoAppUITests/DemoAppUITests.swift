//
//  DemoAppUITests.swift
//  DemoAppUITests
//
//  Created by Ezimet Ozkhan on 1/31/23.
//

import XCTest
@testable import DemoApp

final class DemoAppUITests: XCTestCase {
    let app = XCUIApplication()
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        app.launchArguments = ["isUITest"]
        app.launch()
        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testNewsList() throws {
        // UI tests must launch the application that they test.
        let tableView = app.tables["tableView"]
        _ = tableView.waitForExistence(timeout: 3)
        XCTAssert(tableView.cells.count == 1)

        let cell = tableView.cells.element(matching: .cell, identifier: "news_cell_0")
        XCTAssert(cell.exists)
        XCTAssertEqual(cell.staticTexts["news_cell_title"].label, "NASA Awards Environmental Compliance, Operations Contract")
    }

    func testNewsDetail() throws {
        // UI tests must launch the application that they test.
        let tableView = app.tables["tableView"]
        _ = tableView.waitForExistence(timeout: 3)
        XCTAssert(tableView.cells.count == 1)

        let cell = tableView.cells.element(matching: .cell, identifier: "news_cell_0")
        cell.tap()
        XCTAssert(app.staticTexts[TestingHelper.articleTitleLabelIdentifier].exists)
        XCTAssertEqual(app.staticTexts[TestingHelper.articleTitleLabelIdentifier].label, "NASA Awards Environmental Compliance, Operations Contract")
        XCTAssertEqual(app.staticTexts[TestingHelper.articleSummaryLabelIdentifier].label, "NASA has selected Navarro Research and Engineering, Inc., of Oak Ridge, Tennessee, for the Environmental Compliance and Operations 3 (ECO3) contract, which provides environmental restoration program services and other support at the agency’s White Sands Test Facility in Las Cruces, New Mexico.")
    }
}
