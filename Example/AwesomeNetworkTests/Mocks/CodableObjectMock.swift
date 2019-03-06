//
//  CodableObjectMock.swift
//  AirAsiaNetworking_Example
//
//  Created by Evandro Harrison on 06/03/2019.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import Foundation

struct CodableObjectMock: Codable {
    var name: String?
    
    func encode() throws -> Data? {
        do {
            let encoded = try JSONEncoder().encode(self)
            return encoded
        } catch {
            throw error
        }
    }
    
    static func decode(_ data: Data) throws -> CodableObjectMock {
        do {
            let decoded = try JSONDecoder().decode(self, from: data)
            return decoded
        } catch {
            throw error
        }
    }
    
    static func decodeArray(_ data: Data) throws -> [CodableObjectMock] {
        do {
            let decoded = try JSONDecoder().decode([CodableObjectMock].self, from: data)
            return decoded
        } catch {
            throw error
        }
    }
}
