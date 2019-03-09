//
//  URLRequestExtensionsTests.swift
//  AwesomeNetwork_Tests
//
//  Created by Evandro Harrison on 06/03/2019.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import XCTest
@testable import AwesomeNetwork

class URLRequestExtensionsTests: XCTestCase {

    func testUrlRequestBuild() {
        let url = URL(string: "https://google.com")!
        let data = UUID().uuidString.data(using: .utf8)
        let headers: [String: String] = ["content": "type"]
        let timeout: TimeInterval = 10
        
        let urlRequest = URLRequest.request(with: url)
        XCTAssertNil(urlRequest.httpBody)
        XCTAssertEqual(urlRequest.allHTTPHeaderFields, [:])
        XCTAssertEqual(urlRequest.httpMethod, "GET")
        XCTAssertEqual(urlRequest.timeoutInterval, 15)
        
        let urlRequest2 = URLRequest.request(with: url, method: .POST, bodyData: data, headers: headers, timeoutAfter: timeout)
        XCTAssertEqual(urlRequest2.httpBody, data)
        XCTAssertEqual(urlRequest2.allHTTPHeaderFields, headers)
        XCTAssertEqual(urlRequest2.httpMethod, "POST")
        XCTAssertEqual(urlRequest2.timeoutInterval, timeout)
    }

}
