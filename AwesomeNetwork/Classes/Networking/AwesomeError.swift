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
    
    public static func == (lhs: AwesomeError, rhs: AwesomeError) -> Bool {
        switch (lhs, rhs) {
        case (.invalidUrl, .invalidUrl): return true
        case (.timeOut(let lhe), .timeOut(let rhe)): return lhe == rhe
        case (.unknown(let lhe), .unknown(let rhe)): return lhe == rhe
        case (.cancelled(let lhe), .cancelled(let rhe)): return lhe == rhe
        case (.generic(let lhe), .generic(let rhe)): return lhe == rhe
        case (.noConnection(let lhe), .noConnection(let rhe)): return lhe == rhe
        case (.unauthorized, .unauthorized): return true
        case (.invalidData, .invalidData): return true
        case (.uploadFailed(let lhe), .uploadFailed(let rhe)): return lhe == rhe
        case (.cacheRule(let lhe), .cacheRule(let rhe)): return lhe == rhe
        case (.parse(let lhe), .parse(let rhe)): return lhe == rhe
        case (.error, .error): return true
        default: return false
        }
    }
    
    public var errorDescription: String? {
        return String(describing: self)
    }
}
