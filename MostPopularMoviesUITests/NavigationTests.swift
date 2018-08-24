//
//  NavigationTests.swift
//  MostPopularMoviesUITests
//
//  Created by Alex Magalhaes on 08/12/18.
//  Copyright © 2018 ArcTouch. All rights reserved.
//

import XCTest

class NavigationTests: XCTestCase {
    private let movieTitle: String = "Avengers: Infinity War"

    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        XCUIApplication().launch()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testUserAbleToTapOnMovieCellAndReturnToHomePage() {
        let app = XCUIApplication()
        let movieCell = app.tables.cells.staticTexts[movieTitle]
        if movieCell.waitForExistence(timeout: 10.0) {
            movieCell.tap()
        }

        let movieDetailsTitle = app.scrollViews.otherElements.staticTexts[movieTitle]
        if movieDetailsTitle.waitForExistence(timeout: 5.0) {
            app.navigationBars[movieTitle].buttons["Back"].tap()
        }
    }
}
