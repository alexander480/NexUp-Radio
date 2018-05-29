//
//  NexUp_Unit_Test.swift
//  NexUp Unit Test
//
//  Created by Alexander Lester on 5/21/18.
//  Copyright © 2018 LAGB Technologies. All rights reserved.
//

import XCTest
@testable import NexUp

//  MARK: Unit Test //

class UnitTest: XCTestCase {
    
    override func setUp() {
        super.setUp()
        
        print("-----------------------------------------")
        print("[TEST] UNIT TEST INITIATED")
        print("-----------------------------------------")
    }
    
    override func tearDown() {
        print("-----------------------------------------")
        print("[TEST] UNIT TESTING COMPLETE")
        print("-----------------------------------------")
        
        super.tearDown()
    }
    
}

// MARK: Unit Tests //

extension UnitTest {
    
    func testFavoriteSong() {
        let song = favoriteSong()
    }
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
}

//  MARK: Performance Tests //

extension UnitTest {
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
}
