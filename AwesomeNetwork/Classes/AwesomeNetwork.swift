//
//  AwesomeNetwork.swift
//  AwesomeNetwork
//
//  Created by Evandro Harrison Hoffmann on 25/02/2019.
//  Copyright © 2019 Awesome. All rights reserved.
//

public class AwesomeNetwork {
    
    public static var shared: AwesomeNetwork = AwesomeNetwork()
    
    public var defaultDispatchQueue: DispatchQueue = .global(qos: .default)
    public var defaultCacheRule: AwesomeCacheRule = .fromCacheOrUrl
    public var defaultRequestTimeout: TimeInterval = 15
    public var retryTimeout: TimeInterval = 1
    public var cacheManager: AwesomeCacheManager?
    public var requester: AwesomeRequester?
    let reachability = AwesomeReachability()
    
    public static func start(useSemaphore: Bool = false,
                             defaultDispatchQueue: DispatchQueue = .global(qos: .default),
                             defaultRequestTimeout: TimeInterval = 15,
                             defaultCacheRule: AwesomeCacheRule = .fromCacheOrUrl,
                             retryTimeout: TimeInterval = 1,
                             cacheType: AwesomeCacheType = .realm) {
        shared.defaultDispatchQueue = defaultDispatchQueue
        shared.defaultCacheRule = defaultCacheRule
        shared.defaultRequestTimeout = defaultRequestTimeout
        shared.retryTimeout = retryTimeout
        shared.cacheManager = AwesomeCacheManager(cacheType: cacheType)
        shared.requester = AwesomeRequester(useSemaphore: useSemaphore)
    }
    
    public static func releaseDispatchQueue() {
        AwesomeDispatcher.shared.releaseSemaphore()
    }
    
    public static func clearCache() {
        shared.cacheManager?.clearCache()
    }
    
    public static func cancelAllRequests() {
        shared.requester?.requestManager.cancelAllRequests()
        AwesomeUpload.shared.requestManager.cancelAllRequests()
    }
    
    /// Gets data from cache and return true if should get data from URL
    ///
    /// - Parameters:
    ///   - request: Request Protocol
    ///   - completion: Data or Error
    public static func requestData(with request: AwesomeRequestProtocol,
                                   completion:@escaping AwesomeDataResponse) {
        dataFromCache(with: request, completion: completion, fetchFromUrl: {
            shared.requester?.performRequestRetrying(request, retryCount: request.retryCount) { (data, error) in
                request.saveToCache(data)
                completion(data, error)
            }
        })
    }
    
    /// Request Generic from server
    ///
    /// - Parameters:
    ///   - request: Request Protocol
    ///   - completion: Generic or Error
    public static func requestGeneric<T: Decodable>(with request: AwesomeRequestProtocol,
                                                    completion:@escaping (T?, AwesomeError?) -> Void) {
        requestData(with: request) { (data, error) in
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
    
    /// Request Generic Array from server
    ///
    /// - Parameters:
    ///   - request: Request Protocol
    ///   - completion: Generic array or Error
    public static func requestGeneric<T: Decodable>(with request: AwesomeRequestProtocol,
                                                    completion:@escaping ([T], AwesomeError?) -> Void) {
        requestData(with: request) { (data, error) in
            if let error = error {
                completion([], error)
                return
            }
            
            guard let data = data else {
                completion([], AwesomeError.unknown("No error from server and Data is nil."))
                return
            }
            
            do {
                let generic = try JSONDecoder().decode([T].self, from: data)
                completion(generic, nil)
            } catch {
                completion([], AwesomeError.parse(error.localizedDescription))
            }
        }
    }
    
    /// Gets data from cache and return true if should get data from URL
    ///
    /// - Parameters:
    ///   - request: Request Protocol
    ///   - completion: Data or Error
    ///   - fetchFromUrl: Called if should get from URL
    static func dataFromCache(with request: AwesomeRequestProtocol,
                              completion:@escaping AwesomeDataResponse,
                              fetchFromUrl:@escaping () -> Void) {
        var didReturnCache: Bool = false
        
        // gets from cache if any
        if request.cacheRule.shouldGetFromCache,
            let data = request.cachedData {
            completion(data, nil)
            didReturnCache = true
        }
        
        // proceed to url if set in cache rule
        guard request.cacheRule.shouldGetFromUrl(didReturnCache: didReturnCache) else {
            if !didReturnCache {
                completion(nil, AwesomeError.cacheRule("Cache rule set to get only from cache, but there was no cache for this URL request."))
            }
            return
        }
        
        fetchFromUrl()
    }
    
}
