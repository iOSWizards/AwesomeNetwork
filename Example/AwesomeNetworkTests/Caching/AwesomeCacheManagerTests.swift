//
//  AwesomeRealmCacheTests.swift
//  AwesomeNetwork_Tests
//
//  Created by Evandro Harrison on 25/02/2019.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import XCTest
@testable import AwesomeNetwork

class AwesomeCacheManagerTests: XCTestCase {

    var cacheManager: AwesomeCacheManager!
    
    override func setUp() {
        cacheManager = AwesomeCacheManager()
    }

    override func tearDown() {
        cacheManager.clearCache()
    }

    func testCacheRule() {
        XCTAssertTrue(AwesomeCacheRule.fromCacheAndUrl.shouldGetFromCache)
        XCTAssertTrue(AwesomeCacheRule.fromCacheAndUrl.shouldGetFromUrl(didReturnCache: false))
        XCTAssertTrue(AwesomeCacheRule.fromCacheAndUrl.shouldGetFromUrl(didReturnCache: true))
        XCTAssertTrue(AwesomeCacheRule.fromCacheAndUrl.shouldReturnUrlData(didReturnCache: false))
        XCTAssertTrue(AwesomeCacheRule.fromCacheAndUrl.shouldReturnUrlData(didReturnCache: true))
        
        XCTAssertTrue(AwesomeCacheRule.fromCacheOrUrl.shouldGetFromCache)
        XCTAssertTrue(AwesomeCacheRule.fromCacheOrUrl.shouldGetFromUrl(didReturnCache: false))
        XCTAssertFalse(AwesomeCacheRule.fromCacheOrUrl.shouldGetFromUrl(didReturnCache: true))
        XCTAssertTrue(AwesomeCacheRule.fromCacheOrUrl.shouldReturnUrlData(didReturnCache: false))
        XCTAssertFalse(AwesomeCacheRule.fromCacheOrUrl.shouldReturnUrlData(didReturnCache: true))
        
        XCTAssertTrue(AwesomeCacheRule.fromCacheOnly.shouldGetFromCache)
        XCTAssertFalse(AwesomeCacheRule.fromCacheOnly.shouldGetFromUrl(didReturnCache: false))
        XCTAssertFalse(AwesomeCacheRule.fromCacheOnly.shouldGetFromUrl(didReturnCache: true))
        XCTAssertFalse(AwesomeCacheRule.fromCacheOnly.shouldReturnUrlData(didReturnCache: false))
        XCTAssertFalse(AwesomeCacheRule.fromCacheOnly.shouldReturnUrlData(didReturnCache: true))
        
        XCTAssertFalse(AwesomeCacheRule.fromURL.shouldGetFromCache)
        XCTAssertTrue(AwesomeCacheRule.fromURL.shouldGetFromUrl(didReturnCache: false))
        XCTAssertTrue(AwesomeCacheRule.fromURL.shouldGetFromUrl(didReturnCache: true))
        XCTAssertTrue(AwesomeCacheRule.fromURL.shouldReturnUrlData(didReturnCache: false))
        XCTAssertTrue(AwesomeCacheRule.fromURL.shouldReturnUrlData(didReturnCache: true))
    }
    
    func testSaveCache() {
        let url: URL = URL(string: "https://google.com")!
        let method: URLMethod = .GET
        let body: Data? = nil
        let data: Data? = UUID().uuidString.data(using: .utf8)
        let urlRequest = URLRequest.request(with: url, method: method, bodyData: body)
        
        let dataFromCache1 = cacheManager.verifyForCache(with: urlRequest)
        XCTAssertNil(dataFromCache1)
        
        cacheManager.saveCache(data, with: urlRequest)
        
        let dataFromCache2 = cacheManager.verifyForCache(with: urlRequest)
        XCTAssertNotNil(dataFromCache2)
        XCTAssertEqual(dataFromCache2, data)
        
    }

    func testSaveCacheWithParams() {
        let url: URL = URL(string: "https://google.com")!
        let method: URLMethod = .GET
        let body: Data? = UUID().uuidString.data(using: .utf8)
        let data: Data? = UUID().uuidString.data(using: .utf8)
        let urlRequest = URLRequest.request(with: url, method: method, bodyData: body)
        
        let dataFromCache1 = cacheManager.verifyForCache(with: urlRequest)
        XCTAssertNil(dataFromCache1)
        
        cacheManager.saveCache(data, with: urlRequest)
        
        let dataFromCache2 = cacheManager.verifyForCache(with: URLRequest.request(with: url, method: method, bodyData: body))
        XCTAssertNotNil(dataFromCache2)
        XCTAssertEqual(dataFromCache2, data)
        
        let dataFromCache3 = cacheManager.verifyForCache(with: URLRequest.request(with: url, method: method))
        XCTAssertNil(dataFromCache3)
        
        let dataFromCache4 = cacheManager.verifyForCache(with: URLRequest.request(with: url, method: .POST, bodyData: body))
        XCTAssertNil(dataFromCache4)
        
        let dataFromCache5 = cacheManager.verifyForCache(with: URLRequest.request(with: URL(string: "https://google.com/test")!, method: method, bodyData: body))
        XCTAssertNil(dataFromCache5)
        
        // save a second url to compare with first
        let url2: URL = URL(string: "https://google.com/2")!
        let method2: URLMethod = .GET
        let body2: Data? = UUID().uuidString.data(using: .utf8)
        let data2: Data? = UUID().uuidString.data(using: .utf8)
        let urlRequest2 = URLRequest.request(with: url2, method: method2, bodyData: body2)
        cacheManager.saveCache(data2, with: urlRequest2)
        
        let dataFromCache6 = cacheManager.verifyForCache(with: urlRequest2)
        XCTAssertNotNil(dataFromCache6)
        XCTAssertEqual(dataFromCache6, data2)
        XCTAssertNotEqual(String(data: dataFromCache2!, encoding: .utf8),
                          String(data: dataFromCache6!, encoding: .utf8))
    }
    
    func testClearCache() {
        let url: URL = URL(string: "https://google.com")!
        let method: URLMethod = .GET
        let body: Data? = nil
        let data: Data? = UUID().uuidString.data(using: .utf8)
        let urlRequest = URLRequest.request(with: url, method: method, bodyData: body)
        
        cacheManager.saveCache(data, with: urlRequest)
        
        let dataFromCache1 = cacheManager.verifyForCache(with: urlRequest)
        XCTAssertNotNil(dataFromCache1)
        XCTAssertEqual(dataFromCache1, data)
        
        cacheManager.clearCache()
        
        let dataFromCache2 = cacheManager.verifyForCache(with: urlRequest)
        XCTAssertNil(dataFromCache2)
    }
    
}
