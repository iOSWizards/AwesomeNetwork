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
        
        let request = AwesomeRequestParameters(urlString: "https://google.com", cacheRule: .fromURL)
        AwesomeNetwork.requestData(with: request) { (data, error) in
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
        
        let request = AwesomeRequestParameters(urlString: url, method: method, cacheRule: .fromCacheAndUrl)
        request?.saveToCache(data)
        AwesomeNetwork.requestData(with: request) { (responseData, error) in
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 5)
    }
    
    func testResponseFromCacheOrUrlWithoutCache() {
        let url: String = "https://google.com"
        
        let exp = expectation(description: "testResponseFromCacheOrUrlWithoutCache")
        exp.expectedFulfillmentCount = 1
        
        let request = AwesomeRequestParameters(urlString: url, cacheRule: .fromCacheOrUrl)
        AwesomeNetwork.requestData(with: request) { (data, error) in
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
        
        let request = AwesomeRequestParameters(urlString: url, method: method, cacheRule: .fromCacheOrUrl)
        request?.saveToCache(data)
        
        AwesomeNetwork.requestData(with: request) { (responseData, error) in
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1)
    }
    
    func testResponseFromCacheOnlyWithoutCache() {
        let url: String = "https://google.com"
        
        let exp = expectation(description: "testResponseFromCacheOnlyWithoutCache")
        exp.isInverted = true
        
        let request = AwesomeRequestParameters(urlString: url, cacheRule: .fromCacheOnly)
        
        AwesomeNetwork.requestData(with: request) { (responseData, error) in
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
        
        let request = AwesomeRequestParameters(urlString: url, method: method, cacheRule: .fromCacheOnly)
        request?.saveToCache(data)
        
        AwesomeNetwork.requestData(with: request) { (responseData, error) in
            exp.fulfill()
            XCTAssertEqual(data, responseData)
        }
        
        wait(for: [exp], timeout: 1)
    }
}
