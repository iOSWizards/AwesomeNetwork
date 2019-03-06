import XCTest
@testable import AwesomeNetwork

class AwesomeNetworkTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        AwesomeNetwork.start()
        AwesomeNetwork.shared.requester = AwesomeRequesterMock(expectedData: UUID().uuidString.data(using: .utf8), expectedError: nil)
        AwesomeNetwork.clearCache()
        AwesomeNetwork.shared.defaultRequestTimeout = 15
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testRequestTimeout() {
        AwesomeNetwork.shared.defaultRequestTimeout = 0.1
        AwesomeNetwork.shared.requester = AwesomeRequesterMock(expectedData: nil, expectedError: AwesomeError.timeOut(UUID().uuidString))
        
        let exp = expectation(description: "testRequestTimeout")
        exp.expectedFulfillmentCount = 1
        
        AwesomeNetwork.requestData(from: "https://google.com", cacheRule: .fromURL) { (data, error) in
            exp.fulfill()
            XCTAssertEqual(error!, AwesomeError.timeOut(UUID().uuidString))
        }
        
        wait(for: [exp], timeout: 1)
    }
    
    func testResponseFromCacheAndUrl() {
        let url: String = "https://google.com"
        let method: URLMethod = .GET
        let data = UUID().uuidString.data(using: .utf8)
        
        let exp = expectation(description: "testResponseFromCacheAndUrl")
        exp.expectedFulfillmentCount = 2
        
        AwesomeNetwork.shared.cacheManager?.saveCache(withUrl: url, method: method, body: nil, data: data)
        AwesomeNetwork.requestData(from: url, cacheRule: .fromCacheAndUrl, method: method) { (responseData, error) in
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 5)
    }
    
    func testResponseFromCacheOrUrlWithoutCache() {
        let url: String = "https://google.com"
        
        let exp = expectation(description: "testResponseFromCacheOrUrlWithoutCache")
        exp.expectedFulfillmentCount = 1
        
        AwesomeNetwork.requestData(from: url, cacheRule: .fromCacheOrUrl) { (data, error) in
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1)
    }
    
    func testResponseFromCacheOrUrlWithCache() {
        let url: String = "https://google.com"
        let method: URLMethod = .GET
        let data = UUID().uuidString.data(using: .utf8)
        
        let exp = expectation(description: "testResponseFromCacheOrUrlWithCache")
        exp.expectedFulfillmentCount = 1
        
        AwesomeNetwork.shared.cacheManager?.saveCache(withUrl: url, method: method, body: nil, data: data)
        AwesomeNetwork.requestData(from: url, cacheRule: .fromCacheOrUrl, method: method) { (responseData, error) in
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1)
    }
    
    func testResponseFromCacheOnlyWithoutCache() {
        let url: String = "https://google.com"
        
        let exp = expectation(description: "testResponseFromCacheOnlyWithoutCache")
        exp.isInverted = true
        
        AwesomeNetwork.requestData(from: url, cacheRule: .fromCacheOnly) { (responseData, error) in
            XCTAssertNil(responseData)
            XCTAssertEqual(error!, AwesomeError.cacheRule(UUID().uuidString))
        }
        
        wait(for: [exp], timeout: 1)
    }
    
    func testResponseFromCacheOnlyWithCache() {
        let url: String = "https://google.com"
        let method: URLMethod = .GET
        let data = UUID().uuidString.data(using: .utf8)
        
        let exp = expectation(description: "testResponseFromCacheOrUrlWithCache")
        exp.expectedFulfillmentCount = 1
        
        AwesomeNetwork.shared.cacheManager?.saveCache(withUrl: url, method: method, body: nil, data: data)
        AwesomeNetwork.requestData(from: url, cacheRule: .fromCacheOnly, method: method) { (responseData, error) in
            exp.fulfill()
            XCTAssertEqual(data, responseData)
        }
        
        wait(for: [exp], timeout: 1)
    }
}
