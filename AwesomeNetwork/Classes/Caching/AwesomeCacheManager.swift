//
//  AwesomeCacheManager.swift
//  AwesomeNetwork
//
//  Created by Evandro Harrison Hoffmann on 01/09/2016.
//  Copyright © 2016 Awesome. All rights reserved.
//

import Foundation

public enum AwesomeCacheType {
    case urlCache
    case realm
}

public enum AwesomeCacheRule {
    /// Fetch data from the Cache only
    case fromCacheOnly
    
    /// Fetch data from the Cache, if available. Otherwise fetch from the URL
    /// and update the cache.
    ///
    /// Callback is only fired once, either from the Cache or the URL.
    case fromCacheOrUrl
    
    /// Fetch data from the cache, if available. Otherwise fetch from the URL.
    ///
    /// If the data is fetched from the Cache then a request is also made to the URL
    /// and then the cache is updated with the new data.
    ///
    /// Callback is only fired once, either from the Cache or the URL.
    case fromCacheOrUrlThenUpdate
    
    /// Fetch data from the Cache and the URL.
    ///
    /// Callback fires twice, once from Cache and once from URL.
    case fromCacheAndUrl
    
    /// Fetch data from the URL, bypassing the cache.
    /// Cache is updated with the successfully retrieved data.
    ///
    /// Callback is only fired once.
    case fromURL
    
    public var shouldGetFromCache: Bool {
        switch self {
        case .fromCacheOnly, .fromCacheOrUrl, .fromCacheAndUrl, .fromCacheOrUrlThenUpdate:
            return true
        default:
            return false
        }
    }
    
    public func shouldGetFromUrl(didReturnCache: Bool) -> Bool {
        switch self {
        case .fromCacheOrUrl:
            return !didReturnCache
        case .fromURL, .fromCacheAndUrl, .fromCacheOrUrlThenUpdate:
            return true
        default:
            return false
        }
    }
    
    public func shouldReturnUrlData(didReturnCache: Bool) -> Bool {
        switch self {
        case .fromCacheOnly:
            return false
        case .fromCacheAndUrl, .fromURL:
            return true
        default:
            return !didReturnCache
        }
    }
}

public class AwesomeCacheManager: NSObject {
    
    public var cacheType: AwesomeCacheType = .realm
    
    public init(cacheType: AwesomeCacheType = .realm) {
        super.init()
        
        self.cacheType = cacheType
        AwesomeRealmCache.configureRealmDatabase()
    }
    
    public func clearCache() {
        AwesomeRealmCache.clearDatabase()
    }
    
    public func cache(_ data: Data, forKey key: String) {
        AwesomeRealmCache(key: key, value: data).save()
    }
    
    public func data(forKey key: String) -> Data? {
        return AwesomeRealmCache.data(forKey: key)
    }
    
    // MARK: - Requester methods
    
    public func verifyForCache(with urlRequest: URLRequest) -> Data? {
        if let data = data(forKey: urlRequest.urlCacheKey) {
            return data
        }
        return nil
    }
    
    public func saveCache(_ data: Data?, with urlRequest: URLRequest) {
        if let data = data {
            cache(data, forKey: urlRequest.urlCacheKey)
        }
    }
    
    public func verifyForCache(with cacheKey: String) -> Data? {
        if let data = data(forKey: cacheKey) {
            return data
        }
        return nil
    }
    
    public func saveCache(_ data: Data?, with cacheKey: String) {
        if let data = data {
            cache(data, forKey: cacheKey)
        }
    }
    
}
