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
        
        XCTAssertTrue(AwesomeCacheRule.fromCacheOrUrl.shouldGetFromCache)
        XCTAssertTrue(AwesomeCacheRule.fromCacheOrUrl.shouldGetFromUrl(didReturnCache: false))
        XCTAssertFalse(AwesomeCacheRule.fromCacheOrUrl.shouldGetFromUrl(didReturnCache: true))
        
        XCTAssertTrue(AwesomeCacheRule.fromCacheOnly.shouldGetFromCache)
        XCTAssertFalse(AwesomeCacheRule.fromCacheOnly.shouldGetFromUrl(didReturnCache: false))
        XCTAssertFalse(AwesomeCacheRule.fromCacheOnly.shouldGetFromUrl(didReturnCache: true))
        
        XCTAssertFalse(AwesomeCacheRule.fromURL.shouldGetFromCache)
        XCTAssertTrue(AwesomeCacheRule.fromURL.shouldGetFromUrl(didReturnCache: false))
        XCTAssertTrue(AwesomeCacheRule.fromURL.shouldGetFromUrl(didReturnCache: true))
    }
    
    func testSaveCache() {
        let url: String = UUID().uuidString
        let method: URLMethod = .GET
        let body: Data? = nil
        let data: Data? = UUID().uuidString.data(using: .utf8)
        
        let dataFromCache1 = cacheManager.verifyForCache(withUrl: url, method: method.rawValue, body: body)
        XCTAssertNil(dataFromCache1)
        
        cacheManager.saveCache(withUrl: url, method: method.rawValue, body: body, data: data)
        
        let dataFromCache2 = cacheManager.verifyForCache(withUrl: url, method: method.rawValue, body: body)
        XCTAssertNotNil(dataFromCache2)
        XCTAssertEqual(dataFromCache2, data)
        
    }

    func testSaveCacheWithParams() {
        let url: String = UUID().uuidString
        let method: URLMethod = .GET
        let body: Data? = UUID().uuidString.data(using: .utf8)
        let data: Data? = UUID().uuidString.data(using: .utf8)
        
        let dataFromCache1 = cacheManager.verifyForCache(withUrl: url, method: method.rawValue, body: body)
        XCTAssertNil(dataFromCache1)
        
        cacheManager.saveCache(withUrl: url, method: method.rawValue, body: body, data: data)
        
        let dataFromCache2 = cacheManager.verifyForCache(withUrl: url, method: method.rawValue, body: body)
        XCTAssertNotNil(dataFromCache2)
        XCTAssertEqual(dataFromCache2, data)
        
        let dataFromCache3 = cacheManager.verifyForCache(withUrl: url, method: method.rawValue, body: nil)
        XCTAssertNil(dataFromCache3)
        
        let dataFromCache4 = cacheManager.verifyForCache(withUrl: url, method: URLMethod.POST.rawValue, body: body)
        XCTAssertNil(dataFromCache4)
        
        let dataFromCache5 = cacheManager.verifyForCache(withUrl: UUID().uuidString, method: method.rawValue, body: body)
        XCTAssertNil(dataFromCache5)
        
        // save a second url to compare with first
        let url2: String = UUID().uuidString
        let method2: URLMethod = .GET
        let body2: Data? = UUID().uuidString.data(using: .utf8)
        let data2: Data? = UUID().uuidString.data(using: .utf8)
        cacheManager.saveCache(withUrl: url2, method: method2.rawValue, body: body2, data: data2)
        
        let dataFromCache6 = cacheManager.verifyForCache(withUrl: url2, method: method2.rawValue, body: body2)
        XCTAssertNotNil(dataFromCache6)
        XCTAssertEqual(dataFromCache6, data2)
        XCTAssertNotEqual(String(data: dataFromCache2!, encoding: .utf8),
                          String(data: dataFromCache6!, encoding: .utf8))
    }
    
    func testClearCache() {
        let url: String = UUID().uuidString
        let method: URLMethod = .GET
        let body: Data? = nil
        let data: Data? = UUID().uuidString.data(using: .utf8)
        
        cacheManager.saveCache(withUrl: url, method: method.rawValue, body: body, data: data)
        
        let dataFromCache1 = cacheManager.verifyForCache(withUrl: url, method: method.rawValue, body: body)
        XCTAssertNotNil(dataFromCache1)
        XCTAssertEqual(dataFromCache1, data)
        
        cacheManager.clearCache()
        
        let dataFromCache2 = cacheManager.verifyForCache(withUrl: url, method: method.rawValue, body: body)
        XCTAssertNil(dataFromCache2)
    }

    func testURLCacheKey() {
        let url: String = UUID().uuidString
        let method: URLMethod = .GET
        
        let hashKey = url + "?keyHash=\(url + method.rawValue)"
        let key = AwesomeCacheManager.buildURLCacheKey(url, method: method.rawValue, bodyData: nil)
        XCTAssertEqual(key, hashKey)
        
        let body: Data? = UUID().uuidString.data(using: .utf8)
        let hashKeyWithBody = url + "?keyHash=\(String(data: body!, encoding: .utf8)! + url + method.rawValue)"
        let keyWithBody = AwesomeCacheManager.buildURLCacheKey(url, method: method.rawValue, bodyData: body)
        XCTAssertEqual(keyWithBody, hashKeyWithBody)
    }
    
}
