//
//  AwesomeRequestParameters.swift
//  AwesomeNetwork
//
//  Created by Evandro Harrison on 06/03/2019.
//

import Foundation

public struct AwesomeRequestParameters {
    
    var urlRequest: URLRequest!
    var cacheRule: AwesomeCacheRule = AwesomeNetwork.shared.defaultCacheRule
    var queue: DispatchQueue = AwesomeNetwork.shared.defaultDispatchQueue
    var retryCount: Int = 0
    
    init(urlRequest: URLRequest,
         cacheRule: AwesomeCacheRule = AwesomeNetwork.shared.defaultCacheRule,
         queue: DispatchQueue? = nil,
         retryCount: Int = 0) {
        self.urlRequest = urlRequest
        self.cacheRule = cacheRule
        
        if let queue = queue {
            self.queue = queue
        }
        
        self.retryCount = retryCount
    }
    
    init?(urlString: String?,
          method: URLMethod = .GET,
          bodyData: Data? = nil,
          headers: [String: String]? = nil,
          queryItems: [URLQueryItem]? = nil,
          timeoutAfter timeout: TimeInterval = AwesomeNetwork.shared.defaultRequestTimeout,
          cacheRule: AwesomeCacheRule = AwesomeNetwork.shared.defaultCacheRule,
          queue: DispatchQueue? = nil,
          retryCount: Int = 0) {
        guard let urlString = urlString, let url = urlString.url(withQueryItems: queryItems) else {
            return nil
        }
        
        self.urlRequest = URLRequest.request(with: url,
                                             method: method,
                                             bodyData: bodyData,
                                             headers: headers,
                                             timeoutAfter: timeout)
        self.cacheRule = cacheRule
        
        if let queue = queue {
            self.queue = queue
        }
        
        self.retryCount = retryCount
    }
    
    var cachedData: Data? {
        guard let url = urlRequest.url?.absoluteString else {
            return nil
        }
        
        return AwesomeNetwork.shared.cacheManager?.verifyForCache(withUrl: url,
                                                                  method: urlRequest.httpMethod,
                                                                  body: urlRequest.httpBody)
    }
    
    func saveToCache(_ data: Data?) {
        guard let url = urlRequest.url?.absoluteString else {
            return
        }
        
        AwesomeNetwork.shared.cacheManager?.saveCache(withUrl: url,
                                                      method: urlRequest.httpMethod,
                                                      body: urlRequest.httpBody,
                                                      data: data)
    }
}
