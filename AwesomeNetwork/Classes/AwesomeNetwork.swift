//
//  AwesomeNetwork.swift
//  AwesomeNetwork
//
//  Created by Evandro Harrison Hoffmann on 25/02/2019.
//  Copyright © 2019 Awesome. All rights reserved.
//

public class AwesomeNetwork {
    
    public static var shared: AwesomeNetwork = AwesomeNetwork()
    
    public var useSemaphore: Bool = false
    public var defaultDispatchQueue: DispatchQueue = .global(qos: .default)
    public var defaultCacheRule: AwesomeCacheRule = .fromCacheOrUrl
    public var defaultRequestTimeout: TimeInterval = 15
    public var retryTimeout: TimeInterval = 1
    public var cacheManager: AwesomeCacheManager?
    public var requester: AwesomeRequester?
    public var uploader: AwesomeUpload?
    let reachability = AwesomeReachability()
    
    public static func start(useSemaphore: Bool = false,
                             defaultDispatchQueue: DispatchQueue = .global(qos: .default),
                             defaultRequestTimeout: TimeInterval = 15,
                             defaultCacheRule: AwesomeCacheRule = .fromCacheOrUrl,
                             retryTimeout: TimeInterval = 1,
                             cacheType: AwesomeCacheType = .realm) {
        shared.useSemaphore = useSemaphore
        shared.defaultDispatchQueue = defaultDispatchQueue
        shared.defaultCacheRule = defaultCacheRule
        shared.defaultRequestTimeout = defaultRequestTimeout
        shared.retryTimeout = retryTimeout
        shared.cacheManager = AwesomeCacheManager(cacheType: cacheType)
        shared.requester = AwesomeRequester()
        shared.uploader = AwesomeUpload()
    }
    
    public static func releaseDispatchQueue() {
        AwesomeDispatcher.shared.releaseSemaphore()
    }
    
    public static func clearCache() {
        shared.cacheManager?.clearCache()
    }
    
    public static func cancelAllRequests() {
        shared.requester?.requestManager.cancelAllRequests()
        shared.uploader?.requestManager.cancelAllRequests()
    }
    
    /// Returns data either from cache or from URL
    ///
    /// - Parameters:
    ///   - urlString: URL String
    ///   - cacheRule: Choose from Cache or URL, default is cache falling back to URL
    ///   - method: URL Method
    ///   - bodyData: Data body if any
    ///   - headers: Dictionary of headers
    ///   - timeout: Timeout time in seconds
    ///   - queue: Dispatch queue for request
    ///   - retryCount: Retry count before giving up
    ///   - completion: (data, errorData)
    public static func requestData(from urlString: String?,
                                   cacheRule: AwesomeCacheRule = shared.defaultCacheRule,
                                   method: URLMethod = .GET,
                                   bodyData: Data? = nil,
                                   headers: [String: String]? = nil,
                                   queryItems: [URLQueryItem]? = nil,
                                   timeoutAfter timeout: TimeInterval = shared.defaultRequestTimeout,
                                   usingDispatchQueue queue: DispatchQueue? = nil,
                                   retryCount: Int = 0,
                                   completion:@escaping AwesomeDataResponse) {
        guard let urlString = urlString else {
            completion(nil, AwesomeError.invalidUrl)
            return
        }
        
        var didReturnCache: Bool = false
        
        // gets from cache if any
        if cacheRule.shouldGetFromCache,
            let data = shared.cacheManager?.verifyForCache(withUrl: urlString, method: method, body: bodyData) {
            completion(data, nil)
            didReturnCache = true
        }
        
        // proceed to url if set in cache rule
        guard cacheRule.shouldGetFromUrl(didReturnCache: didReturnCache) else {
            if !didReturnCache {
                completion(nil, AwesomeError.cacheRule("Cache rule set to get only from cache, but there was no cache for this URL request."))
            }
            return
        }
    
        shared.requester?.performRequest(urlString,
                                         method: method,
                                         bodyData: bodyData,
                                         headers: headers,
                                         queryItems: queryItems,
                                         timeoutAfter: timeout,
                                         useSemaphore: shared.useSemaphore,
                                         queue: queue) { (data, error) in
            // caches data
            shared.cacheManager?.saveCache(withUrl: urlString, method: method, body: bodyData, data: data)
            
            completion(data, error)
        }
    }
    
    static func requestGeneric<T: Decodable>(from urlString: String?,
                                             cacheRule: AwesomeCacheRule = shared.defaultCacheRule,
                                             method: URLMethod = .GET,
                                             bodyData: Data? = nil,
                                             headers: [String: String]? = nil,
                                             queryItems: [URLQueryItem]? = nil,
                                             timeoutAfter timeout: TimeInterval = shared.defaultRequestTimeout,
                                             usingDispatchQueue queue: DispatchQueue? = nil,
                                             retryCount: Int = 0,
                                             completion:@escaping (T?, AwesomeError?) -> Void) {
        requestData(from: urlString, cacheRule: cacheRule, method: method, bodyData: bodyData, headers: headers, queryItems: queryItems, timeoutAfter: timeout, usingDispatchQueue: queue, retryCount: retryCount) { (data, error) in
            if let error = error {
                completion(nil, error)
                return
            }
            
            guard let data = data else {
                completion(nil, AwesomeError.unknown("No error from server and Data is nil."))
                return
            }
            
            do {
                let generic = try JSONDecoder().decode(T.self, from: data)
                completion(generic, nil)
            } catch {
                completion(nil, AwesomeError.parse(error.localizedDescription))
            }
        }
    }
}
