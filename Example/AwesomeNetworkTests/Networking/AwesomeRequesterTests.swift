//
//  AwesomeRequesterTests.swift
//  AwesomeNetwork_Tests
//
//  Created by Evandro Harrison on 26/02/2019.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import XCTest
@testable import AwesomeNetwork

class AwesomeRequesterTests: XCTestCase {
    
    override func setUp() {
        AwesomeNetwork.start()
        AwesomeDispatcher.shared.hasGreenLights = false
        AwesomeNetwork.shared.requester?.requestManager.requestQueue.removeAll()
    }
    
    override func tearDown() {
        AwesomeNetwork.clearCache()
    }
    
    func testAwesomeError() {
        XCTAssertEqual(AwesomeError.invalidUrl, AwesomeError.invalidUrl)
        XCTAssertEqual(AwesomeError.timeOut(UUID().uuidString), AwesomeError.timeOut(UUID().uuidString))
        XCTAssertNotEqual(AwesomeError.timeOut(UUID().uuidString), AwesomeError.cacheRule(UUID().uuidString))
    }

    func testPerformRequestUrlError() {
        let exp = expectation(description: "testPerformRequestUrlError")
        exp.expectedFulfillmentCount = 2
        
        AwesomeNetwork.shared.requester = AwesomeRequesterMock(expectedData: nil, expectedError: AwesomeError.invalidUrl)
        
        AwesomeNetwork.shared.requester?.performRequest(nil, useSemaphore: false) { (data, error) in
            exp.fulfill()
            XCTAssertNil(data)
            XCTAssertEqual(error!, AwesomeError.invalidUrl)
        }
        
        AwesomeNetwork.shared.requester?.performRequest("", useSemaphore: false) { (data, error) in
            exp.fulfill()
            XCTAssertNil(data)
            XCTAssertEqual(error!, AwesomeError.invalidUrl)
        }
        
        wait(for: [exp], timeout: 1)
    }
    
    func testSemaphoreGivenGreenLights() {
        let exp = expectation(description: "testSemaphoreGivenGreenLights")
        exp.expectedFulfillmentCount = 1
        
        AwesomeNetwork.shared.requester = AwesomeRequesterMock(expectedData: UUID().uuidString.data(using: .utf8), expectedError: nil)
        
        AwesomeNetwork.shared.requester?.performRequest("https://www.google.com", useSemaphore: true) { (data, error) in
            exp.fulfill()
        }
        
        AwesomeNetwork.releaseDispatchQueue()
        
        wait(for: [exp], timeout: 1)
    }
    
    func testRequestQueue() {
        let exp = expectation(description: "testRequestQueue")
        exp.expectedFulfillmentCount = 1
        
        AwesomeNetwork.shared.requester = AwesomeRequesterMock(expectedData: UUID().uuidString.data(using: .utf8), expectedError: nil)
        
        XCTAssertEqual(AwesomeNetwork.shared.requester?.requestManager.requestQueue.count, 0)
        AwesomeNetwork.shared.requester?.performRequest("https://www.google.com", useSemaphore: false) { (data, error) in
            exp.fulfill()
            XCTAssertEqual(AwesomeNetwork.shared.requester?.requestManager.requestQueue.count, 0)
        }
        XCTAssertEqual(AwesomeNetwork.shared.requester?.requestManager.requestQueue.count, 1)
        
        AwesomeNetwork.releaseDispatchQueue()
        
        wait(for: [exp], timeout: 1)
    }
 
    func testRetry() {
        let exp = expectation(description: "testRetry")
        exp.expectedFulfillmentCount = 1
        
        AwesomeNetwork.shared.requester?.performRequest("http://", useSemaphore: false, retryCount: 2) { (data, error) in
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 5)
    }
}
