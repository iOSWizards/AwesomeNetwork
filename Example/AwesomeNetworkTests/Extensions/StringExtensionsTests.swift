//
//  StringExtensionsTests.swift
//  AwesomeNetwork_Tests
//
//  Created by Evandro Harrison on 27/02/2019.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import XCTest
@testable import AwesomeNetwork

class StringExtensionsTests: XCTestCase {

    func testUrlConversion() {
        let urlString = "https://www.google.com"
        XCTAssertEqual(urlString.url(), URL(string: urlString))
        XCTAssertEqual(urlString.url(withQueryItems: nil), URL(string: urlString))
        XCTAssertEqual(urlString.url(withQueryItems: [URLQueryItem(name: "test", value: "value")]), URL(string: urlString.appending("?test=value")))
        XCTAssertEqual(urlString.url(withQueryItems: [URLQueryItem(name: "test", value: "value"), URLQueryItem(name: "test2", value: "value2")]), URL(string: urlString.appending("?test=value&test2=value2")))
    }

}
