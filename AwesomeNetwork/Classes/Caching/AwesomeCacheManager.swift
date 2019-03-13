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
    case fromCacheOnly
    case fromCacheOrUrl
    case fromCacheOrUrlThenUpdate // returns cache or URL data, then fetchs data from URL but doesn't return
    case fromCacheAndUrl
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
        case .fromCacheOrUrlThenUpdate, .fromCacheOnly:
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
    
    func cache(_ data: Data, forKey key: String) {
        AwesomeRealmCache(key: key, value: data).save()
    }
    
    func data(forKey key: String) -> Data? {
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
    
}
