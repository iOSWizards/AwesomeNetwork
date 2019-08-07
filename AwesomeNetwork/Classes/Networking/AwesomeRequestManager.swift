//
//  AwesomeRequestManager.swift
//  AwesomeNetwork
//
//  Created by Evandro Harrison on 28/02/2019.
//

import Foundation

class AwesomeRequestManager {
    
    var requestQueue: [String: URLSessionTask?] = [:]
    
    func addRequest(to urlRequest: URLRequest, task: URLSessionTask, cancelPrevious: Bool = false) {
        if cancelPrevious {
            requestQueue[urlRequest.urlCacheKey]??.cancel()
        }
        requestQueue[urlRequest.urlCacheKey] = task
    }
    
    func removeRequest(to urlRequest: URLRequest) {
        DispatchQueue.main.sync {
            requestQueue[urlRequest.urlCacheKey] = nil
        }
    }
    
    func cancelRequest(to urlRequest: URLRequest) {
        requestQueue[urlRequest.urlCacheKey]??.cancel()
        removeRequest(to: urlRequest)
    }
    
    func cancelAllRequests() {
        for request in requestQueue.values {
            request?.cancel()
        }
        
        requestQueue.removeAll()
    }
}
