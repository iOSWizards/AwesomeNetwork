//
//  AwesomeParserTests.swift
//  AwesomeNetwork_Example
//
//  Created by Evandro Harrison on 08/03/2019.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import XCTest
@testable import AwesomeNetwork

class AwesomeParserTests: XCTestCase {
    
    func testParseSingleObject() {
        let mockObject = CodableObjectMock(name: UUID().uuidString)
        let data = try! mockObject.encode()
        
        let parsedObject: CodableObjectMock? = try? AwesomeParser.parseSingle(data)
        
        XCTAssertNotNil(parsedObject)
        XCTAssertEqual(mockObject.name, parsedObject?.name)
    }
    
    func testParseArray() {
        let mockObjects = [CodableObjectMock(name: UUID().uuidString),
                           CodableObjectMock(name: UUID().uuidString),
                           CodableObjectMock(name: UUID().uuidString)]
        let data = "[{\"name\": \"\(mockObjects[0].name!)\"},{\"name\": \"\(mockObjects[1].name!)\"},{\"name\": \"\(mockObjects[2].name!)\"}]".data(using: .utf8)
        
        let parsedArray: [CodableObjectMock] = try! AwesomeParser.parseArray(data)
        
        XCTAssertEqual(parsedArray.count, mockObjects.count)
        XCTAssertEqual(parsedArray.first?.name, mockObjects.first?.name)
    }
}
