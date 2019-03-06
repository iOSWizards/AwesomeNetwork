//
//  AwesomeDispatcherTests.swift
//  AwesomeNetwork_Tests
//
//  Created by Evandro Harrison on 27/02/2019.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import XCTest
@testable import AwesomeNetwork

class AwesomeDispatcherTests: XCTestCase {

    override func setUp() {
        AwesomeDispatcher.shared = AwesomeDispatcher()
    }

    override func tearDown() {
        
    }

    func testSemaphoreTimeout() {
        AwesomeDispatcher.shared.timeout = 1
        
        let exp = expectation(description: "testSemaphoreTimeout")
        exp.expectedFulfillmentCount = 2
        
        AwesomeDispatcher.shared.executeBlock(signalNext: false) {
            exp.fulfill()
        }
        
        AwesomeDispatcher.shared.executeBlock {
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 2)
    }
    
    func testSemaphoreDidGetSignalNext() {
        let exp = expectation(description: "testSemaphoreDidGetSignalNext")
        exp.expectedFulfillmentCount = 2
        
        AwesomeDispatcher.shared.executeBlock {
            exp.fulfill()
        }
        
        AwesomeDispatcher.shared.executeBlock {
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 2)
    }
}
