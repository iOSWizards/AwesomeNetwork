//
//  AwesomeRequestManagerTests.swift
//  AwesomeNetwork_Tests
//
//  Created by Evandro Harrison on 28/02/2019.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import XCTest
@testable import AwesomeNetwork

class AwesomeRequestManagerTests: XCTestCase {

    var requestManager: AwesomeRequestManager!
    
    override func setUp() {
        requestManager = AwesomeRequestManager()
    }

    override func tearDown() {
        
    }

    func testAddRemoveRequest() {
        XCTAssertEqual(requestManager.requestQueue.count, 0)
        
        let mock = AwesomeRequestManagerTestsMock(url: "https://google.com")
        mock.performMockRequest(completion: {
            // completed
        }) {
            // canceled
        }
        
        requestManager.addRequest(to: mock.urlRequest, task: mock.mockTask!)
        
        XCTAssertEqual(requestManager.requestQueue.count, 1)
        
        requestManager.removeRequest(to: mock.urlRequest)
        
        XCTAssertEqual(requestManager.requestQueue.count, 0)
    }
    
    func testCancelRequest() {
        XCTAssertEqual(requestManager.requestQueue.count, 0)
        
        let exp = expectation(description: "testCancelRequest")
        exp.expectedFulfillmentCount = 1
        
        let mock = AwesomeRequestManagerTestsMock(url: "https://google.com")
        mock.performMockRequest(completion: {
            // completed
        }) {
            // canceled
            exp.fulfill()
        }
        
        requestManager.addRequest(to: mock.urlRequest, task: mock.mockTask!)
        
        XCTAssertEqual(requestManager.requestQueue.count, 1)
        
        requestManager.cancelRequest(to: mock.urlRequest)
        
        XCTAssertEqual(requestManager.requestQueue.count, 0)
        
        wait(for: [exp], timeout: 1)
    }

    func testCancelAllRequests() {
        XCTAssertEqual(requestManager.requestQueue.count, 0)
        
        let exp = expectation(description: "testCancelAllRequests")
        exp.expectedFulfillmentCount = 2
        
        let mock = AwesomeRequestManagerTestsMock(url: "https://google.com/1")
        mock.performMockRequest(completion: {
            // completed
        }) {
            // canceled
            exp.fulfill()
        }
        requestManager.addRequest(to: mock.urlRequest, task: mock.mockTask!)
        
        XCTAssertEqual(requestManager.requestQueue.count, 1)
        
        let mock2 = AwesomeRequestManagerTestsMock(url: "https://google.com/2")
        mock2.performMockRequest(completion: {
            // completed
        }) {
            // canceled
            exp.fulfill()
        }
        requestManager.addRequest(to: mock2.urlRequest, task: mock2.mockTask!)
        
        XCTAssertEqual(requestManager.requestQueue.count, 2)
        
        requestManager.cancelAllRequests()
        
        XCTAssertEqual(requestManager.requestQueue.count, 0)
        
        wait(for: [exp], timeout: 1)
    }
}

fileprivate class AwesomeRequestManagerTestsMock {
    
    var urlRequest: URLRequest!
    var mockTask: URLSessionDataTask?
    
    init(url: String) {
        urlRequest = URLRequest.request(with: url.url()!, method: .GET)
    }
    
    func performMockRequest(completion: @escaping () -> Void, canceled: @escaping () -> Void) {
        
        let session = URLSession.shared
        mockTask = session.dataTask(with: urlRequest as URLRequest) { (data, response, error) in
            
            if let error = error {
                let urlError = error as NSError
                if urlError.code == URLError.cancelled.rawValue {
                    canceled()
                }
            } else {
                completion()
            }
        }
        mockTask?.resume()
    }
    
}
