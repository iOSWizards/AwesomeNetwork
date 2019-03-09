//
//  AwesomeRequesterProtocolTests.swift
//  AwesomeNetwork_Example
//
//  Created by Evandro Harrison on 08/03/2019.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import Foundation

import XCTest
@testable import AwesomeNetwork

class AwesomeRequesterProtocolTests: XCTestCase {
    
    func testURLRequestBuiltSuccessfully() {
        class RequestMock: AwesomeRequestProtocol {
            var urlString: String {
                return "https://www.Awesome.com"
            }
        }
        let request = RequestMock()
        
        XCTAssertNotNil(request.urlRequest)
        XCTAssertEqual(request.urlRequest?.url, URL(string: "https://www.Awesome.com")!)
        XCTAssertEqual(request.urlRequest?.allHTTPHeaderFields, [:])
        XCTAssertEqual(request.urlRequest?.timeoutInterval, 15)
        XCTAssertNil(request.urlRequest?.httpBody)
    }
    
    func testURLRequestBuiltSuccessfullyWithItems() {
        class RequestMock: AwesomeRequestProtocol {
            var urlString: String {
                return "https://www.Awesome.com"
            }
            
            var queryItems: [URLQueryItem]? {
                return [URLQueryItem(name: "name", value: "value")]
            }
            
            var timeout: TimeInterval {
                return 10
            }
        }
        let request = RequestMock()
        
        XCTAssertNotNil(request.urlRequest)
        XCTAssertEqual(request.urlRequest?.url, URL(string: "https://www.Awesome.com?name=value")!)
        XCTAssertEqual(request.urlRequest?.allHTTPHeaderFields, [:])
        XCTAssertEqual(request.urlRequest?.timeoutInterval, 10)
        XCTAssertNil(request.urlRequest?.httpBody)
    }
    
    /*func testURLRequestSuccessResponseGeneric() {
        class RequestMock: AwesomeRequestProtocol {
            var urlString: String {
                return "https://www.Awesome.com"
            }
            
            func isSuccessResponse(_ response: CodableObjectMock?) -> Bool {
                return response?.success ?? false
            }
        }
        let request = RequestMock()
        
        let mockCodable = CodableObjectMock(name: UUID().uuidString, success: true)
        XCTAssertTrue(request.isSuccessResponse(mockCodable))
        
        let mockCodable2 = CodableObjectMock(name: UUID().uuidString, success: false)
        XCTAssertFalse(request.isSuccessResponse(mockCodable2))
    }*/
    
    func testURLRequestSuccessResponseDataDefault() {
        class RequestMock: AwesomeRequestProtocol {
            var urlString: String {
                return "https://www.Awesome.com"
            }
        }
        let request = RequestMock()
        
        let data = UUID().uuidString.data(using: .utf8)
        XCTAssertTrue(request.isSuccessResponse(data))
        
        XCTAssertFalse(request.isSuccessResponse(nil))
    }
    
    func testURLRequestSuccessResponseDataCustom() {
        class RequestMock: AwesomeRequestProtocol {
            var urlString: String {
                return "https://www.Awesome.com"
            }
            
            func isSuccessResponse(_ response: Data?) -> Bool {
                guard let response = response else {
                    return false
                }
                
                return String(data: response, encoding: .utf8) != nil
            }
        }
        let request = RequestMock()
        
        let data = UUID().uuidString.data(using: .utf8)
        XCTAssertTrue(request.isSuccessResponse(data))
        
        XCTAssertFalse(request.isSuccessResponse(nil))
    }
}
