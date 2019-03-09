//
//  AwesomeDownloadManager.swift
//  AwesomeNetwork
//
//  Created by Evandro Harrison on 26/02/2019.
//

import UIKit

public enum AwesomeDownloadEvent: String {
    case downloading
    case downloaded
    case deleted
    case downloadCanceled
    case deleteCanceled
    
    public var notificationName: Notification.Name {
        return Notification.Name(rawValue: rawValue)
    }
}

public struct AwesomeDownloadObject {
    let url: URL?
    let progress: Float
    
    init(url: URL?, progress: Float = 0) {
        self.url = url
        self.progress = progress
    }
}

public struct AwesomeDownloadManager {
    
    /// Observe to Specified download event
    ///
    /// - Parameters:
    ///   - event: AwesomeDownloadEvent (downloading, downloaded, deleted, downloadCanceled, deleteCanceled)
    ///   - queue: Queue for Operation
    ///   - url: url to compare if observed notification is the expected one
    ///   - using: Callback with notification object
    public static func observe(to event: AwesomeDownloadEvent, inQueue queue: OperationQueue = .main, whenUrl url: URL? = nil, using: @escaping (Notification) -> Void) {
        
        NotificationCenter.default.addObserver(forName: AwesomeDownloadEvent.downloaded.notificationName, object: nil, queue: queue) { (notification) in
            if let url = url {
                if let downloadObject = notification.object as? AwesomeDownloadObject, downloadObject.url == url {
                    using(notification)
                }
                return
            }
            
            using(notification)
        }

    }
    
    static func notify(_ event: AwesomeDownloadEvent, with object: AwesomeDownloadObject? = nil) {
        NotificationCenter.default.post(name: event.notificationName, object: object)
    }
    
    public static func download(from urls: [URL]) {
        cancelDownloads()
        
        guard urls.count > 0 else {
            return
        }
        
        var urls = urls
        let url = urls.removeFirst()
        
        notify(.downloading, with: AwesomeDownloadObject(url: url))
        
        AwesomeDownload.download(from: url, completion: { (success) in
            notify(.downloaded, with: AwesomeDownloadObject(url: url, progress: 1))
            AwesomeDownloadManager.download(from: urls)
        }, progressUpdated: {(progress) in
            notify(.downloading, with: AwesomeDownloadObject(url: url, progress: progress))
        })
    }
    
    public static func delete(from urls: [URL],
                              fromView: UIView,
                              viewController: UIViewController,
                              title: String,
                              message: String,
                              confirm: String,
                              cancel: String) {
        cancelDownloads()
        
        guard urls.count > 0 else {
            return
        }
        
        // we should delete the media.
        let alertController = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .actionSheet)
        
        alertController.addAction(UIAlertAction(
            title: confirm,
            style: .destructive,
            handler: { (action) in
                for url in urls {
                    if url.deleteOfflineFile() {
                        notify(.deleted, with: AwesomeDownloadObject(url: url, progress: 0))
                    }
                }
        }))
        
        alertController.addAction(UIAlertAction(title: cancel, style: .cancel, handler: { (action) in
            notify(.deleteCanceled)
        }))
        
        alertController.popoverPresentationController?.sourceView = fromView
        alertController.popoverPresentationController?.sourceRect = fromView.bounds
        
        viewController.present(alertController, animated: true, completion: nil)
    }
    
    fileprivate static func cancelDownloads() {
        AwesomeDownload.shared.cancelDownload()
        //notify(.downloadCanceled)
    }
    
}
