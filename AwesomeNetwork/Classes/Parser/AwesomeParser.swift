//
//  AwesomeParser.swift
//  AwesomeNetwork
//
//  Created by Evandro Harrison on 07/03/2019.
//

import Foundation

public struct AwesomeParser {
    
    public static func parseSingle<T: Decodable>(_ data: Data?) throws -> T {
        guard let data = data else {
            throw AwesomeError.invalidData
        }
        
        do {
            let generic = try JSONDecoder().decode(T.self, from: data)
            return generic
        } catch {
            throw AwesomeError.parse(error.localizedDescription)
        }
    }
    
    public static func parseArray<T: Decodable>(_ data: Data?) throws -> [T] {
        guard let data = data else {
            throw AwesomeError.invalidData
        }
        
        do {
            let generic = try JSONDecoder().decode([T].self, from: data)
            return generic
        } catch {
            throw AwesomeError.parse(error.localizedDescription)
        }
    }
    
}
