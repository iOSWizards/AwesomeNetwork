//
//  AwesomeRequestManager.swift
//  AwesomeNetwork
//
//  Created by Evandro Harrison on 28/02/2019.
//

import Foundation

class AwesomeRequestManager {
    
    var requestQueue: [String: URLSessionTask] = [:]
    
    func addRequest(to url: URL, task: URLSessionTask) {
        requestQueue[url.path]?.cancel()
        requestQueue[url.path] = task
    }
    
    func removeRequest(to url: URL) {
        requestQueue[url.path] = nil
    }
    
    func cancelRequest(to url: URL) {
        requestQueue[url.path]?.cancel()
        removeRequest(to: url)
    }
    
    func cancelAllRequests() {
        for request in requestQueue.values {
            request.cancel()
        }
        
        requestQueue.removeAll()
    }
}
