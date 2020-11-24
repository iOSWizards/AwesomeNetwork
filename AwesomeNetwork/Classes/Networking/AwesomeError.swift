//
//  AwesomeError.swift
//  AwesomeNetwork
//
//  Created by Evandro Harrison on 06/03/2019.
//

import Foundation

public enum AwesomeError: Error, Equatable, LocalizedError {
    case invalidUrl
    case timeOut(String?)
    case unknown(String?)
    case cancelled(String?)
    case generic(String?)
    case noConnection(String?)
    case unauthorized
    case invalidData
    case uploadFailed(String?)
    case cacheRule(String?)
    case parse(String?)
    case error(Error)
    
    private var baseCode: Int { -1000 }
    
    var errorCode: Int {
        switch self {
        case .invalidUrl:       return baseCode - 1
        case .timeOut(_):       return baseCode - 2
        case .unknown(_):       return baseCode - 3
        case .cancelled(_):     return baseCode - 4
        case .generic(_):       return baseCode - 5
        case .noConnection(_):  return baseCode - 6
        case .unauthorized:     return baseCode - 7
        case .invalidData:      return baseCode - 8
        case .uploadFailed(_):  return baseCode - 9
        case .cacheRule(_):     return baseCode - 10
        case .parse(_):         return baseCode - 11
        case .error(_):         return baseCode - 12
        }
    }
    
    public static func == (lhs: AwesomeError, rhs: AwesomeError) -> Bool {
        switch (lhs, rhs) {
        case (.invalidUrl, .invalidUrl): return true
        case (.timeOut(_), .timeOut(_)): return true
        case (.unknown(_), .unknown(_)): return true
        case (.cancelled(_), .cancelled(_)): return true
        case (.generic(_), .generic(_)): return true
        case (.noConnection(_), .noConnection(_)): return true
        case (.unauthorized, .unauthorized): return true
        case (.invalidData, .invalidData): return true
        case (.uploadFailed(_), .uploadFailed(_)): return true
        case (.cacheRule(_), .cacheRule(_)): return true
        case (.parse(_), .parse(_)): return true
        case (.error, .error): return true
        default: return false
        }
    }
    
    /// Returns the associated error message if any is present OR
    /// return a description of self if no error message is present.
    public var errorDescription: String? {
        switch self {
        case .timeOut(let error):       return error
        case .unknown(let error):       return error
        case .cancelled(let error):     return error
        case .generic(let error):       return error
        case .noConnection(let error):  return error
        case .uploadFailed(let error):  return error
        case .cacheRule(let error):     return error
        case .parse(let error):         return error
        default: return String(describing: self)
        }
    }
    
    /// String describing the error without it's own associated value, if any.
    ///
    /// Note: Use `errorDescription` if you need the associated value as well.
    public var descriptionWithoutValue: String {
        let string = String(describing: self)
        if let valueIndex = string.firstIndex(of: "(") {
            return String(string[..<valueIndex])
        }
        
        return string
    }
    
    /// Make an `NSError` with the given domain and userInfo, if any.
    /// If no domain or userInfo is provided then a default value is
    /// assigned to both.
    ///
    /// - Parameters:
    ///   - domain: The domain of the error.
    ///   - userInfo: The userInfo dictionary.
    /// - Returns: An `NSError` instance.
    public func makeNSError(domain: String? = nil, userInfo: [String: String]? = nil) -> NSError {
        var userInfo = userInfo ?? [String: String]()
        if userInfo[NSLocalizedDescriptionKey] == nil {
            userInfo[NSLocalizedDescriptionKey] = errorDescription
        }

        return NSError(domain: domain ?? "NetworkingError.\(descriptionWithoutValue)", code: errorCode, userInfo: userInfo)
    }
}
