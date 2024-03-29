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
        exp.expectedFulfillmentCount = 1
        
        class RequestMock: AwesomeRequestProtocol {
            var urlString: String {
                return ""
            }
        }
        let request = RequestMock()
        
        AwesomeNetwork.shared.requester = AwesomeRequesterMock(expectedData: nil, expectedError: AwesomeError.invalidUrl)
        
        AwesomeNetwork.shared.requester?.performRequest(request) { (data, error) in
            exp.fulfill()
            XCTAssertNil(data)
            XCTAssertEqual(error!, AwesomeError.invalidUrl)
        }
        
        wait(for: [exp], timeout: 1)
    }
    
    func testSemaphoreGivenGreenLights() {
        let exp = expectation(description: "testSemaphoreGivenGreenLights")
        exp.expectedFulfillmentCount = 1
        
        class RequestMock: AwesomeRequestProtocol {
            var urlString: String {
                return "https://www.Awesome.com"
            }
        }
        let request = RequestMock()
        
        AwesomeNetwork.shared.requester = AwesomeRequesterMock(expectedData: UUID().uuidString.data(using: .utf8), expectedError: nil)
        AwesomeNetwork.shared.requester?.useSemaphore = true
        
        AwesomeNetwork.shared.requester?.performRequest(request) { (data, error) in
            exp.fulfill()
        }
        
        AwesomeNetwork.releaseDispatchQueue()
        
        wait(for: [exp], timeout: 1)
    }
    
    func testRequestQueue() {
        let exp = expectation(description: "testRequestQueue")
        exp.expectedFulfillmentCount = 1
        
        class RequestMock: AwesomeRequestProtocol {
            var urlString: String {
                return "https://www.Awesome.com"
            }
        }
        let request = RequestMock()
        
        AwesomeNetwork.shared.requester = AwesomeRequesterMock(expectedData: UUID().uuidString.data(using: .utf8), expectedError: nil)
        
        XCTAssertEqual(AwesomeNetwork.shared.requester?.requestManager.requestQueue.count, 0)
        AwesomeNetwork.shared.requester?.performRequest(request) { (data, error) in
            exp.fulfill()
            XCTAssertEqual(AwesomeNetwork.shared.requester?.requestManager.requestQueue.count, 0)
        }
        XCTAssertEqual(AwesomeNetwork.shared.requester?.requestManager.requestQueue.count, 1)
        
        AwesomeNetwork.releaseDispatchQueue()
        
        wait(for: [exp], timeout: 1)
    }
    
    func testRetry() {
        let exp = expectation(description: "testRetry")
        exp.expectedFulfillmentCount = 4
        
        class RequestMock: AwesomeRequestProtocol {
            var urlString: String {
                return "https://"
            }
            
            var retryCount: Int {
                return 2
            }
            
            func isSuccessResponse(_ response: Data?) -> Bool {
                return false
            }
        }
        let request = RequestMock()
        let requester = AwesomeRequesterMock(expectedData: UUID().uuidString.data(using: .utf8), expectedError: nil)
        
        requester.performRequestRetrying(request,
                                         retryCount: request.retryCount,
                                         intermediate: { (data, error, count) in
                                            exp.fulfill()
        }, completion: { (data, error) in
            exp.fulfill()
        })
        
        wait(for: [exp], timeout: 10)
    }
}
