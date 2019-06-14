//
//  StringExtensions.swift
//  AwesomeNetwork
//
//  Created by Evandro Harrison on 25/02/2019.
//

import Foundation

extension URL {
    public static var documentsDirectory: URL {
        return FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
    }
    
    public static func destination(for folder: String) -> URL {
        return URL.documentsDirectory.appendingPathComponent(folder)
    }
    
    public func offlineFileDestination(withFolder folder: String? = AwesomeDownload.shared.defaultDownloadFolder) -> URL {
        if let folder = folder {
            return URL.destination(for: folder).appendingPathComponent(lastPathComponent)
        }
        return URL.documentsDirectory.appendingPathComponent(lastPathComponent)
    }
    
    public var offlineFileName: String {
        return lastPathComponent
    }
    
    public func createFolder() {
        do {
            try FileManager().createDirectory(at: self, withIntermediateDirectories: true, attributes: nil)
        } catch {
            print("folder could not be created")
        }
    }
    
    public func offlineFileExists(withFolder folder: String? = AwesomeDownload.shared.defaultDownloadFolder) -> Bool {
        return FileManager().fileExists(atPath: offlineFileDestination(withFolder: folder).path)
    }
    
    public func offlineURLIfAvailable(withFolder folder: String? = AwesomeDownload.shared.defaultDownloadFolder) -> URL {
        if offlineFileExists(withFolder: folder) {
            return offlineFileDestination(withFolder: folder)
        }
        return self
    }
    
    public func deleteOfflineFile(withFolder folder: String? = AwesomeDownload.shared.defaultDownloadFolder) -> Bool {
        guard offlineFileExists(withFolder: folder) else {
            return false
        }
        
        do {
            try FileManager().removeItem(at: offlineFileDestination(withFolder: folder))
            return true
        } catch let error as NSError {
            print(error.localizedDescription)
            return false
        }
    }
    
    public func moveOfflineFile(to: URL, completion:@escaping (Bool) -> Void) {
        do {
            try FileManager().moveItem(at: self, to: to)
            print("File moved to documents folder: \(to.absoluteString)")
            completion(true)
        } catch let error as NSError {
            print(error.localizedDescription)
            completion(false)
        }
    }
}
