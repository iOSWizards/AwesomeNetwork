//
//  AwesomeRequestParameters.swift
//  AwesomeNetwork
//
//  Created by Evandro Harrison on 06/03/2019.
//

import Foundation

public protocol AwesomeRequestProtocol {
    var urlString: String { get }
    var body: Data? { get }
    var queryItems: [URLQueryItem]? { get }
    var headers: AwesomeRequesterHeader? { get }
    var timeout: TimeInterval { get }
    var method: URLMethod { get }
    var urlRequest: URLRequest? { get }
    var cacheRule: AwesomeCacheRule { get }
    var queue: DispatchQueue { get }
    var retryCount: Int { get }
    var cancelPreviousRequest: Bool { get }
    var cacheKey: String? { get }
    
    //func isSuccessResponse<T: Decodable>(_ response: T?) -> Bool
    func isSuccessResponse(_ response: Data?) -> Bool
}

extension AwesomeRequestProtocol {
    
    public var body: Data? {
        return nil
    }
    
    public var queryItems: [URLQueryItem]? {
        return nil
    }
    
    public var headers: AwesomeRequesterHeader? {
        return nil
    }
    
    public var timeout: TimeInterval {
        return AwesomeNetwork.shared.defaultRequestTimeout
    }
    
    public var method: URLMethod {
        return .GET
    }
    
    public var urlRequest: URLRequest? {
        guard let url = urlString.url(withQueryItems: queryItems) else {
            return nil
        }
        
        return URLRequest.request(with: url,
                                  method: method,
                                  bodyData: body,
                                  headers: headers,
                                  timeoutAfter: timeout)
    }
    
    public var cacheRule: AwesomeCacheRule {
        return AwesomeNetwork.shared.defaultCacheRule
    }
    
    public var queue: DispatchQueue {
        return AwesomeNetwork.shared.defaultDispatchQueue
    }
    
    public var retryCount: Int {
        return 0
    }
    
    public var cancelPreviousRequest: Bool {
        return false
    }
    
    public var cacheKey: String? {
        return nil
    }
    
    public var cachedData: Data? {
        if let cacheKey = cacheKey {
            return AwesomeNetwork.shared.cacheManager?.verifyForCache(with: cacheKey)
        }
        
        guard let urlRequest = urlRequest else {
            return nil
        }
        
        return AwesomeNetwork.shared.cacheManager?.verifyForCache(with: urlRequest)
    }
    
    public func saveToCache(_ data: Data?) {
        if let cacheKey = cacheKey {
            AwesomeNetwork.shared.cacheManager?.saveCache(data, with: cacheKey)
            return
        }
        
        guard let urlRequest = urlRequest else {
            return
        }
        
        AwesomeNetwork.shared.cacheManager?.saveCache(data, with: urlRequest)
    }
    
    /*public func isSuccessResponse<T: Decodable>(_ response: T?) -> Bool {
        return true
    }*/
    
    public func isSuccessResponse(_ response: Data?) -> Bool {
        return response != nil
    }
}
