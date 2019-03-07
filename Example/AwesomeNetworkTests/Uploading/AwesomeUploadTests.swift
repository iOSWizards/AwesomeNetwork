//
//  AwesomeUploadTests.swift
//  AwesomeNetwork_Example
//
//  Created by Evandro Harrison on 06/03/2019.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import XCTest
@testable import AwesomeNetwork

class AwesomeUploadTests: XCTestCase {
    
    override func setUp() {
        
    }
    
    override func tearDown() {
        
    }
    
    func testUploadUrlError() {
        let exp = expectation(description: "testUploadUrlError")
        exp.expectedFulfillmentCount = 2
        
        let uploader = AwesomeUploadMock(expectedData: nil, expectedError: AwesomeError.invalidUrl)
        
        uploader.upload(nil, to: nil, headers: nil) { (data, error) in
            exp.fulfill()
            XCTAssertNil(data)
            XCTAssertEqual(error!, AwesomeError.invalidUrl)
        }
        
        uploader.upload(nil, to: "", headers: nil) { (data, error) in
            exp.fulfill()
            XCTAssertNil(data)
            XCTAssertEqual(error!, AwesomeError.invalidUrl)
        }
        
        wait(for: [exp], timeout: 1)
    }
    
    func testUploadDataError() {
        let exp = expectation(description: "testUploadDataError")
        exp.expectedFulfillmentCount = 1
        
        let urlString = "https://google.com"
        let uploader = AwesomeUploadMock(expectedData: nil, expectedError: AwesomeError.invalidData)
        
        uploader.upload(nil, to: urlString, headers: nil) { (data, error) in
            exp.fulfill()
            XCTAssertNil(data)
            XCTAssertEqual(error!, AwesomeError.invalidData)
        }
        
        wait(for: [exp], timeout: 1)
    }
    
    func testUploadData() {
        let exp = expectation(description: "testUploadData")
        exp.expectedFulfillmentCount = 1
        
        let urlString = "https://google.com"
        let uploader = AwesomeUploadMock(expectedData: UUID().uuidString.data(using: .utf8), expectedError: nil)
        
        uploader.upload(uploader.expectedData, to: urlString, headers: nil) { (data, error) in
            exp.fulfill()
            XCTAssertEqual(data, uploader.expectedData)
        }
        
        wait(for: [exp], timeout: 1)
    }
    
    func testRequestQueue() {
        let exp = expectation(description: "testRequestQueue")
        exp.expectedFulfillmentCount = 1
        
        let urlString = "https://google.com"
        let uploader = AwesomeUploadMock(expectedData: UUID().uuidString.data(using: .utf8), expectedError: nil)
        
        XCTAssertEqual(uploader.requestManager.requestQueue.count, 0)
        uploader.upload(uploader.expectedData, to: urlString, headers: nil) { (data, error) in
            exp.fulfill()
            XCTAssertEqual(uploader.requestManager.requestQueue.count, 0)
        }
        XCTAssertEqual(uploader.requestManager.requestQueue.count, 1)
        
        wait(for: [exp], timeout: 1)
    }
    
}
