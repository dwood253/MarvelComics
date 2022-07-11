//
//  MarvelComicsUITests.swift
//  MarvelComicsUITests
//
//  Created by Daniel on 7/6/22.
//

import XCTest

class MarvelComicsUITests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testHomeCollectionExistsAndLoadedCells() throws {
        let app = XCUIApplication()
        app.launch()
        let cells = app.collectionViews.children(matching: .any).element(boundBy: 0)
        XCTAssertTrue(cells.waitForExistence(timeout: 3))
    }
    
    func testComicDetailsViewLoads() throws {
        let app = XCUIApplication()
        app.launch()
        
        let collectionViewsQuery = app.collectionViews
        collectionViewsQuery.children(matching: .cell).element(boundBy: 2).children(matching: .other).element.tap()
        
        let elementsQuery = app.scrollViews.otherElements
        XCTAssertTrue(elementsQuery.staticTexts["READ NOW"].exists)
        XCTAssertTrue(elementsQuery.staticTexts["MARK AS READ"].exists)
        XCTAssertTrue(elementsQuery.staticTexts["ADD TO LIBRARY"].exists)
        XCTAssertTrue(elementsQuery.staticTexts["READ OFFLINE"].exists)
    }

    func testLaunchPerformance() throws {
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 7.0, *) {
            // This measures how long it takes to launch your application.
            measure(metrics: [XCTApplicationLaunchMetric()]) {
                XCUIApplication().launch()
            }
        }
    }
}
