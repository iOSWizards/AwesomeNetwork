//
//  URLExtensionsTests.swift
//  AwesomeNetwork_Tests
//
//  Created by Evandro Harrison on 27/02/2019.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import XCTest
@testable import AwesomeNetwork

class URLExtensionsTests: XCTestCase {

    func testDocumentsDirectory() {
        XCTAssertEqual(URL.documentsDirectory.lastPathComponent, "Documents")
    }
    
    func testDestination() {
        let folderName = UUID().uuidString
        XCTAssertEqual(URL.destination(for: folderName).lastPathComponent, folderName)
    }

    func testOfflineFileDestination() {
        let fileName = UUID().uuidString.appending(".pdf")
        let url = URL(string: "https://www.google.com/\(fileName)")!
        XCTAssertEqual(url.offlineFileDestination().lastPathComponent, fileName)
        XCTAssertEqual(url.offlineFileDestination(withFolder: "folder").lastPathComponent, fileName)
    }
    
    func testOfflineFileName() {
        let fileName = UUID().uuidString.appending(".pdf")
        let url = URL(string: "https://www.google.com/\(fileName)")!
        XCTAssertEqual(url.offlineFileName, fileName)
    }
    
    func testOfflineFileExists() {
        let mock = URLExtensionsTestsMock()
        
        XCTAssertFalse(mock.url.offlineFileExists())
        
        mock.createFile()
        
        XCTAssertTrue(mock.url.offlineFileExists())
    }
    
    func testOfflineURLIfAvailable() {
        let mock = URLExtensionsTestsMock()
        
        XCTAssertFalse(mock.url.offlineFileExists())
        XCTAssertEqual(mock.url.offlineURLIfAvailable(), mock.url)
        
        mock.createFile()
        
        XCTAssertTrue(mock.url.offlineFileExists())
        XCTAssertEqual(mock.url.offlineURLIfAvailable().path, mock.offlineFileUrl.path)
    }
    
    public func testCreateFolder() {
        let folderName = UUID().uuidString
        let url = URL.destination(for: folderName)
        var isDir : ObjCBool = false
        
        XCTAssertFalse(FileManager().fileExists(atPath: url.path, isDirectory: &isDir))
        
        url.createFolder()
        
        XCTAssertTrue(FileManager().fileExists(atPath: url.path, isDirectory: &isDir))
    }
    
    func testDeleteOfflineFile() {
        let mock = URLExtensionsTestsMock()
        
        XCTAssertFalse(mock.url.offlineFileExists())
        
        mock.createFile()
        
        XCTAssertTrue(mock.url.offlineFileExists())
        XCTAssertTrue(mock.url.deleteOfflineFile())
        XCTAssertFalse(mock.url.offlineFileExists())
    }
    
    func moveOfflineFile() {
        let mock = URLExtensionsTestsMock()
        
        XCTAssertFalse(mock.url.offlineFileExists())
        
        mock.createFile()
        
        XCTAssertTrue(mock.url.offlineFileExists())
        
        let exp = expectation(description: "moveOfflineFile")
        exp.expectedFulfillmentCount = 1
        
        let folderName = UUID().uuidString
        let newUrl = URL.destination(for: folderName)
        mock.offlineFileUrl.moveOfflineFile(to: newUrl) { (success) in
            exp.fulfill()
            XCTAssertTrue(success)
            XCTAssertFalse(mock.url.offlineFileExists())
            XCTAssertTrue(FileManager().fileExists(atPath: newUrl.path))
        }
        
        wait(for: [exp], timeout: 1)
    }
}

fileprivate struct URLExtensionsTestsMock {
    
    let fileName: String
    let url: URL
    let offlineFileUrl: URL
    let data: Data?
    
    init() {
        fileName = UUID().uuidString.appending(".pdf")
        url = URL(string: "https://www.google.com/\(fileName)")!
        offlineFileUrl = url.offlineFileDestination()
        data = UUID().uuidString.data(using: .utf8)
    }
    
    func createFile() {
        offlineFileUrl.createFolder()
        FileManager().createFile(atPath: offlineFileUrl.path, contents: data, attributes: nil)
    }
    
    var folderExists: Bool {
        var isDir : ObjCBool = false
        return FileManager().fileExists(atPath: url.path, isDirectory: &isDir)
    }
    
}
