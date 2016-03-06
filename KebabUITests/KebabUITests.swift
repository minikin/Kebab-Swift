//
//  KebabUITests.swift
//  KebabUITests
//
//  Created by Sasha Prokhorenko on 9/18/15.
//  Copyright © 2015 Minikin. All rights reserved.
//

import XCTest

class KebabUITests: XCTestCase {
        
    override func setUp() {
        super.setUp()
        
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
      XCUIDevice.sharedDevice().orientation = .Portrait
      XCUIDevice.sharedDevice().orientation = .Portrait
      
      let app = XCUIApplication()
      app.navigationBars["Kebab_O_Clock.RootView"].buttons["Settings"].tap()
      // Failed to find matching element please file bug (bugreport.apple.com) and provide output from Console.app
      
      let tablesQuery2 = app.tables
      let staticText = tablesQuery2.staticTexts["700 m"]
      staticText.tap()
      
      let tablesQuery = tablesQuery2
      tablesQuery.staticTexts["200 m"].tap()
      tablesQuery.staticTexts["1500 m"].tap()
      staticText.tap()
      
      let kebabOClockRadiustableviewNavigationBar = app.navigationBars["Kebab_O_Clock.RadiusTableView"]
      kebabOClockRadiustableviewNavigationBar.childrenMatchingType(.Other).element.tap()
      kebabOClockRadiustableviewNavigationBar.childrenMatchingType(.Button).elementBoundByIndex(0).tap()
      
      let textView = tablesQuery2.childrenMatchingType(.Cell).elementBoundByIndex(3).childrenMatchingType(.TextView).elementBoundByIndex(0)
      textView.tap()
      textView.tap()
      
      let showOnlyOpenNowVenuesSwitch = tablesQuery.switches["Show only open now venues"]
      showOnlyOpenNowVenuesSwitch.tap()
      showOnlyOpenNowVenuesSwitch.tap()
      // Failed to find matching element please file bug (bugreport.apple.com) and provide output from Console.app
      tablesQuery.staticTexts["Kebab"].tap()
      tablesQuery.staticTexts["Pizza"].tap()
      tablesQuery.staticTexts["Pies"].tap()
      tablesQuery.staticTexts["Sandwiches"].tap()
      tablesQuery.staticTexts["Rolls"].tap()
      app.navigationBars["Kebab_O_Clock.CategoriesTableView"].buttons["Back"].tap()
      app.otherElements.containingType(.NavigationBar, identifier:"Kebab_O_Clock.StaticSettingsTableView").childrenMatchingType(.Other).element.childrenMatchingType(.Other).element.childrenMatchingType(.Table).element.tap()
      app.navigationBars["Kebab_O_Clock.StaticSettingsTableView"].buttons["Back"].tap()
      
      let collectionViewsQuery2 = app.collectionViews
      let cellsQuery = collectionViewsQuery2.cells
      cellsQuery.otherElements.childrenMatchingType(.Image).elementBoundByIndex(0).swipeLeft()
      app.otherElements.containingType(.NavigationBar, identifier:"Kebab_O_Clock.RootView").childrenMatchingType(.Other).element.childrenMatchingType(.Other).element.childrenMatchingType(.Other).element.childrenMatchingType(.CollectionView).element.swipeLeft()
      
      let collectionViewsQuery = collectionViewsQuery2
      let bijuBubbleTeaRoomStaticText = collectionViewsQuery.staticTexts["Biju Bubble Tea Room"]
      bijuBubbleTeaRoomStaticText.swipeRight()
      cellsQuery.otherElements.containingType(.StaticText, identifier:"Carpo Piccadilly").childrenMatchingType(.Image).elementBoundByIndex(0).swipeLeft()
      collectionViewsQuery.staticTexts["Fortnum & Mason"].tap()
      cellsQuery.otherElements.containingType(.StaticText, identifier:"Fortnum & Mason").childrenMatchingType(.Image).elementBoundByIndex(0).swipeLeft()
      bijuBubbleTeaRoomStaticText.tap()
      cellsQuery.otherElements.containingType(.StaticText, identifier:"Carpo Piccadilly").element.tap()
      
      let page1Of5PageIndicator = tablesQuery.pageIndicators["page 1 of 5"]
      page1Of5PageIndicator.tap()
      
      let page5Of5PageIndicator = tablesQuery.pageIndicators["page 5 of 5"]
      page5Of5PageIndicator.swipeLeft()
      page5Of5PageIndicator.tap()
      page5Of5PageIndicator.tap()
      
      let page4Of5PageIndicator = tablesQuery.pageIndicators["page 4 of 5"]
      page4Of5PageIndicator.tap()
      
      let page3Of5PageIndicator = tablesQuery.pageIndicators["page 3 of 5"]
      page3Of5PageIndicator.tap()
      // Failed to find matching element please file bug (bugreport.apple.com) and provide output from Console.app
      // Failed to find matching element please file bug (bugreport.apple.com) and provide output from Console.app
      // Failed to find matching element please file bug (bugreport.apple.com) and provide output from Console.app
      
      let closeButton = tablesQuery.cells.buttons["Close"]
      closeButton.tap()
      
      let kebabOClockDetailstableviewNavigationBar = app.navigationBars["Kebab_O_Clock.DetailsTableView"]
      kebabOClockDetailstableviewNavigationBar.childrenMatchingType(.Button).elementBoundByIndex(0).tap()
      cellsQuery.otherElements.containingType(.StaticText, identifier:"Damson & Co").childrenMatchingType(.Image).elementBoundByIndex(0).swipeLeft()
      page1Of5PageIndicator.tap()
      page5Of5PageIndicator.tap()
      page5Of5PageIndicator.tap()
      page5Of5PageIndicator.tap()
      page5Of5PageIndicator.tap()
      page4Of5PageIndicator.tap()
      page3Of5PageIndicator.tap()
      tablesQuery.pageIndicators["page 2 of 5"].tap()

      closeButton.tap()
      kebabOClockDetailstableviewNavigationBar.buttons["Back"].tap()
      continueAfterFailure = false
        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        XCUIApplication().launch()

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // Use recording to get started writing UI tests.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
}
