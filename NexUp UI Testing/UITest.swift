//
//  NexUp_UI_Testing.swift
//  NexUp UI Testing
//
//  Created by Alexander Lester on 5/21/18.
//  Copyright © 2018 LAGB Technologies. All rights reserved.
//

import XCTest

class UITest: XCTestCase {
        
    override func setUp() {
        super.setUp()
        
        print("-----------------------------------------")
        print("[TEST] TESTING USER INTERFACE")
        print("-----------------------------------------")
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        XCUIApplication().launch()

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }
    
    override func tearDown() {
        print("-----------------------------------------")
        print("[TEST] USER INTERFACE TESTING COMPLETE")
        print("-----------------------------------------")
        
        super.tearDown()
    }
    
    func testExample() {
        // Use recording to get started writing UI tests.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
}
