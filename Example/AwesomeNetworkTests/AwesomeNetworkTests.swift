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
        
        class RequestMock: AwesomeRequestProtocol {
            var urlString: String {
                return "https://www.Awesome.com"
            }
            
            var cacheRule: AwesomeCacheRule {
                return  .fromURL
            }
        }
        let request = RequestMock()
        
        AwesomeNetwork.requestData(with: request) { (data, error) in
            exp.fulfill()
            XCTAssertEqual(error!, AwesomeError.timeOut(UUID().uuidString))
        }
        
        wait(for: [exp], timeout: 1)
    }
    
    func testResponseFromCacheAndUrl() {
        let data = UUID().uuidString.data(using: .utf8)
        
        let exp = expectation(description: "testResponseFromCacheAndUrl")
        exp.expectedFulfillmentCount = 2
        
        class RequestMock: AwesomeRequestProtocol {
            var urlString: String {
                return "https://www.Awesome.com"
            }
            
            var cacheRule: AwesomeCacheRule {
                return  .fromCacheAndUrl
            }
            
            var method: URLMethod {
                return .GET
            }
        }
        let request = RequestMock()
        request.saveToCache(data)
        
        AwesomeNetwork.requestData(with: request) { (responseData, error) in
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 5)
    }
    
    func testResponseFromCacheOrUrlWithoutCache() {
        let exp = expectation(description: "testResponseFromCacheOrUrlWithoutCache")
        exp.expectedFulfillmentCount = 1
        
        class RequestMock: AwesomeRequestProtocol {
            var urlString: String {
                return "https://www.Awesome.com"
            }
            
            var cacheRule: AwesomeCacheRule {
                return  .fromCacheOrUrl
            }
            
            var method: URLMethod {
                return .GET
            }
        }
        let request = RequestMock()
        
        AwesomeNetwork.requestData(with: request) { (data, error) in
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1)
    }
    
    func testResponseFromCacheOrUrlWithCache() {
        let data = UUID().uuidString.data(using: .utf8)
        
        let exp = expectation(description: "testResponseFromCacheOrUrlWithCache")
        exp.expectedFulfillmentCount = 1
        
        class RequestMock: AwesomeRequestProtocol {
            var urlString: String {
                return "https://www.Awesome.com"
            }
            
            var cacheRule: AwesomeCacheRule {
                return  .fromCacheOrUrl
            }
            
            var method: URLMethod {
                return .GET
            }
        }
        let request = RequestMock()
        request.saveToCache(data)
        
        AwesomeNetwork.requestData(with: request) { (responseData, error) in
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1)
    }
    
    func testResponseFromCacheOnlyWithoutCache() {
        let exp = expectation(description: "testResponseFromCacheOnlyWithoutCache")
        exp.isInverted = true
        
        class RequestMock: AwesomeRequestProtocol {
            var urlString: String {
                return "https://www.Awesome.com"
            }
            
            var cacheRule: AwesomeCacheRule {
                return  .fromCacheOnly
            }
            
            var method: URLMethod {
                return .GET
            }
        }
        let request = RequestMock()
        
        AwesomeNetwork.requestData(with: request) { (responseData, error) in
            XCTAssertNil(responseData)
            XCTAssertEqual(error!, AwesomeError.cacheRule(UUID().uuidString))
        }
        
        wait(for: [exp], timeout: 1)
    }
    
    func testResponseFromCacheOnlyWithCache() {
        let data = UUID().uuidString.data(using: .utf8)
        
        let exp = expectation(description: "testResponseFromCacheOrUrlWithCache")
        exp.expectedFulfillmentCount = 1
        
        class RequestMock: AwesomeRequestProtocol {
            var urlString: String {
                return "https://www.Awesome.com"
            }
            
            var cacheRule: AwesomeCacheRule {
                return  .fromCacheOnly
            }
            
            var method: URLMethod {
                return .GET
            }
        }
        let request = RequestMock()
        request.saveToCache(data)
        
        AwesomeNetwork.requestData(with: request) { (responseData, error) in
            exp.fulfill()
            XCTAssertEqual(data, responseData)
        }
        
        wait(for: [exp], timeout: 1)
    }
    
    func testRequestGeneric() {
        let mockObject = CodableObjectMock(name: UUID().uuidString)
        let data = try! mockObject.encode()
        
        let exp = expectation(description: "testResponseFromCacheOrUrlWithCache")
        exp.expectedFulfillmentCount = 1
        
        AwesomeNetwork.shared.requester = AwesomeRequesterMock(expectedData: data, expectedError: nil)
        
        class RequestMock: AwesomeRequestProtocol {
            var urlString: String {
                return "https://www.Awesome.com"
            }
        }
        let request = RequestMock()
        request.saveToCache(data)
        
        AwesomeNetwork.requestGeneric(with: request) { (object: CodableObjectMock?, error) in
            exp.fulfill()
            XCTAssertEqual(object?.name, mockObject.name)
        }
        
        wait(for: [exp], timeout: 1)
    }
    
    func testRequestGenericArray() {
        let mockObjects = [CodableObjectMock(name: UUID().uuidString),
                           CodableObjectMock(name: UUID().uuidString),
                           CodableObjectMock(name: UUID().uuidString)]
        let data = "[{\"name\": \"\(mockObjects[0].name!)\"},{\"name\": \"\(mockObjects[1].name!)\"},{\"name\": \"\(mockObjects[2].name!)\"}]".data(using: .utf8)
        
        let exp = expectation(description: "testResponseFromCacheOrUrlWithCache")
        exp.expectedFulfillmentCount = 1
        
        AwesomeNetwork.shared.requester = AwesomeRequesterMock(expectedData: data, expectedError: nil)
        
        class RequestMock: AwesomeRequestProtocol {
            var urlString: String {
                return "https://www.Awesome.com"
            }
        }
        let request = RequestMock()
        request.saveToCache(data)
        
        AwesomeNetwork.requestGeneric(with: request) { (objects: [CodableObjectMock], error) in
            exp.fulfill()
            XCTAssertEqual(objects.count, mockObjects.count)
            XCTAssertEqual(objects.first?.name, mockObjects.first?.name)
        }
        
        wait(for: [exp], timeout: 1)
    }
    
}
