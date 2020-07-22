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
    
    public static func == (lhs: AwesomeError, rhs: AwesomeError) -> Bool {
        switch (lhs, rhs) {
        case (.invalidUrl, .invalidUrl): return true
        case (.timeOut, .timeOut): return true
        case (.unknown, .unknown): return true
        case (.cancelled, .cancelled): return true
        case (.generic, .generic): return true
        case (.noConnection, .noConnection): return true
        case (.unauthorized, .unauthorized): return true
        case (.invalidData, .invalidData): return true
        case (.uploadFailed, .uploadFailed): return true
        case (.cacheRule, .cacheRule): return true
        case (.parse, .parse): return true
        default: return false
        }
    }
    
    public var errorDescription: String? {
        return String(describing: self)
    }
}
