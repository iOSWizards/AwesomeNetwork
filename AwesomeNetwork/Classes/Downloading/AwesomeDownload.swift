//
//  StringExtensions.swift
//  AwesomeNetwork
//
//  Created by Evandro Harrison on 25/02/2019.
//

import Foundation
import UIKit

public typealias ProgressCallback = (Float) -> ()
public typealias DownloadedCallback = (Bool) -> ()

public enum AwesomeDownloadState {
    case downloading
    case downloaded
    case none
}

public class AwesomeDownload: NSObject {
    
    // public shared
    public static var shared = AwesomeDownload()
    public var defaultDownloadFolder: String = "aaNetworking"
    
    // Private variables
    fileprivate var session: URLSession?
    fileprivate var downloadTask: URLSessionDownloadTask?
    fileprivate var downloadUrl: URL?
    fileprivate var downloadFolder: String?
    
    // Callbacks
    public var progressCallback: ProgressCallback?
    public var downloadedCallback: DownloadedCallback?
    
    public static func downloadState(withUrl url: URL?, folder: String? = shared.defaultDownloadFolder) -> AwesomeDownloadState {
        guard let downloadUrl = url else {
            return .none
        }
        
        if downloadUrl.offlineFileExists(withFolder: folder) {
            print("File \(downloadUrl) is offline")
            return .downloaded
        }
        
        return .none
    }
    
    public static func download(from url: URL?, toFolder folder: String? = shared.defaultDownloadFolder, force: Bool = false, completion: @escaping DownloadedCallback, progressUpdated: @escaping ProgressCallback){
        guard let downloadUrl = url else {
            completion(false)
            return
        }
        
        // to check if it exists before downloading it
        if downloadUrl.offlineFileExists(withFolder: folder) {
            print("The file already exists at path: \(downloadUrl.offlineFileDestination(withFolder: folder).absoluteString)")
            
            if force {
                print("Forcing download, so deleting file from: \(downloadUrl.offlineFileDestination(withFolder: folder).absoluteString).")
                _ = downloadUrl.deleteOfflineFile(withFolder: folder)
                self.download(from: url, toFolder: folder, force: false, completion: completion, progressUpdated: progressUpdated)
            } else {
                completion(true)
            }
        } else {
            shared.downloadFolder = folder
            shared.progressCallback = progressUpdated
            shared.downloadedCallback = completion
            shared.startDownloadSession(withUrl: downloadUrl)
        }
    }
    
    public static func delete(from url: URL?, fromFolder folder: String? = shared.defaultDownloadFolder) -> Bool {
        guard let downloadUrl = url else {
            return false
        }
        
        return downloadUrl.deleteOfflineFile(withFolder: folder)
    }
    
}

extension AwesomeDownload {
    
    fileprivate func startDownloadSession(withUrl url: URL) {
        downloadUrl = url
        
        cancelDownload()
        
        let configuration = URLSessionConfiguration.default
        //let queue = NSOperationQueue.mainQueue()
        
        session = URLSession(configuration: configuration, delegate: self, delegateQueue: nil)
        downloadTask = session?.downloadTask(with: url)
        downloadTask?.resume()
    }
    
    fileprivate func finishDownloadSession() {
        session?.finishTasksAndInvalidate()
        session = nil
        downloadTask?.cancel()
        downloadTask = nil
    }
    
    public func cancelDownload() {
        downloadTask?.cancel()
        session?.invalidateAndCancel()
    }
}

extension AwesomeDownload: URLSessionDelegate, URLSessionDownloadDelegate {
    
    public func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        
        finishDownloadSession()
        
        guard let downloadUrl = downloadUrl else {
            return
        }
        
        // create folder in case we still don't have one
        if let downloadFolder = downloadFolder {
            URL.destination(for: downloadFolder).createFolder()
        }
        
        location.moveOfflineFile(to: downloadUrl.offlineFileDestination(withFolder: downloadFolder), completion: { (success) in
            DispatchQueue.main.async {
                self.downloadedCallback?(success)
            }
        })
    }
    
    public func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        let progress = Float(totalBytesWritten)/Float(totalBytesExpectedToWrite)
        
        DispatchQueue.main.async {
            self.progressCallback?(progress)
        }
    }
}


extension UIViewController {
    
    public func confirmDelete(withUrl url: URL?, fromView: UIView? = nil, withTitle title: String, withMessage message: String, withConfirmButtonTitle confirmButtonTitle:String, withCancelButtonTitle cancelButtonTitle:String, completion:@escaping (Bool) -> Void) {
        guard let downloadUrl = url else {
            completion(false)
            return
        }
        
        // we should delete the media.
        let alertController = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .actionSheet)
        
        alertController.addAction(UIAlertAction(
            title: confirmButtonTitle,
            style: .destructive,
            handler: { (action) in
                let deleted = downloadUrl.deleteOfflineFile()
                DispatchQueue.main.async {
                    completion(deleted)
                }
        }))
        
        alertController.addAction(UIAlertAction(title: cancelButtonTitle, style: .cancel, handler: { (action) in
        
        }))
    
        if let fromView = fromView {
            alertController.popoverPresentationController?.sourceView = fromView
            alertController.popoverPresentationController?.sourceRect = fromView.bounds
        }
    
        present(alertController, animated: true, completion: nil)
    }
}
