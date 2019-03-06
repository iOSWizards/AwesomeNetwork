//
//  NetworkRequester.swift
//  AwesomeNetwork
//
//  Created by Evandro Harrison Hoffmann on 10/03/18.
//  Copyright © 2018 Awesome. All rights reserved.
//

import UIKit

public enum URLMethod: String {
    case GET
    case POST
    case DELETE
    case PUT
    case PATCH
}

public typealias AwesomeDataResponse = (Data?, AwesomeError?) -> Void
public typealias AwesomeRequesterHeader = [String: String]

public class AwesomeRequester: NSObject {
    
    var requestManager: AwesomeRequestManager = AwesomeRequestManager()
    
    /// Fetch data from URL with NSUrlSession
    ///
    /// - Parameters:
    ///   - urlString: Url to fetch data form
    ///   - method: URL method to fetch data using URLMethod enum
    ///   - bodyData: Request body data
    ///   - headers: Any header values to complete the request
    ///   - timeout: When true it will force an update by fetching content from the given URL and storing it in URLCache.
    ///   - usingDispatchQueue: Allows choice if using or not the dispatch queue
    ///   - completion: Returns fetched NSData in a block
    /// - Returns: URLSessionDataTask
    func performRequest(
        _ urlString: String?,
        method: URLMethod? = .GET,
        bodyData: Data? = nil,
        headers: AwesomeRequesterHeader? = nil,
        queryItems: [URLQueryItem]? = nil,
        timeoutAfter timeout: TimeInterval = 15,
        useSemaphore: Bool,
        queue: DispatchQueue? = nil,
        retryCount: Int = 0,
        completion:@escaping AwesomeDataResponse) {
        
        guard let url = urlString?.url(withQueryItems: queryItems) else{
            completion(nil, AwesomeError.invalidUrl)
            return
        }
        
        if useSemaphore {
            AwesomeDispatcher.shared.executeBlock(queue: queue) { [weak self] in
               self?.performRequestRetrying(url: url,
                                            method: method,
                                            bodyData: bodyData,
                                            headers: headers,
                                            timeoutAfter: timeout,
                                            retryCount: retryCount,
                                            completion: completion)
            }
        } else {
            performRequestRetrying(url: url,
                                   method: method,
                                   bodyData: bodyData,
                                   headers: headers,
                                   timeoutAfter: timeout,
                                   retryCount: retryCount,
                                   completion: completion)
        }
        
    }
    
    func performRequestRetrying(
        url: URL,
        method: URLMethod? = .GET,
        bodyData: Data? = nil,
        headers: [String: String]? = nil,
        timeoutAfter timeout: TimeInterval = 15,
        queue: DispatchQueue? = nil,
        retryCount: Int,
        completion:@escaping AwesomeDataResponse) {
        
        performRequest(url: url,
                       method: method,
                       bodyData: bodyData,
                       headers: headers,
                       timeoutAfter: timeout) { [weak self] (data, error) in
                        
                        if data == nil, retryCount > 0 {
                            // adds a small timeout between calls
                            let queue = queue ?? AwesomeDispatcher.shared.defaultQueue
                            queue.asyncAfter(deadline: .now()+AwesomeNetwork.shared.retryTimeout, execute: {
                                self?.performRequestRetrying(url: url,
                                                             method: method,
                                                             bodyData: bodyData,
                                                             headers: headers,
                                                             timeoutAfter: timeout,
                                                             retryCount: retryCount-1,
                                                             completion: completion)
                            })
                        } else {
                            completion(data, error)
                        }
        }
    }
    
    /// Fetch data from URL with NSUrlSession
    ///
    /// - Parameters:
    ///   - url: Url to fetch data form
    ///   - method: URL method to fetch data using URLMethod enum
    ///   - bodyData: Request body data
    ///   - headers: Any header values to complete the request
    ///   - timeout: When true it will force an update by fetching content from the given URL and storing it in URLCache.
    ///   - completion: Returns fetched NSData in a block
    /// - Returns: URLSessionDataTask
    func performRequest(
        url: URL,
        method: URLMethod? = .GET,
        bodyData: Data? = nil,
        headers: [String: String]? = nil,
        timeoutAfter timeout: TimeInterval = 15,
        completion:@escaping AwesomeDataResponse) {
        
        // URL request configurations
        
        let urlRequest = URLRequest.request(with: url,
                                            method: method,
                                            bodyData: bodyData,
                                            headers: headers,
                                            timeoutAfter: timeout)
        
        let session = URLSession.shared
        let dataTask = session.dataTask(with: urlRequest) { (data, response, error) in
            self.requestManager.removeRequest(to: url)
            
            if let error = error {
                print("There was an error \(error.localizedDescription)")
                
                let urlError = error as NSError
                if urlError.code == NSURLErrorTimedOut {
                    completion(nil, AwesomeError.timeOut(error.localizedDescription))
                } else if urlError.code == NSURLErrorNotConnectedToInternet {
                    completion(nil, AwesomeError.noConnection(error.localizedDescription))
                } else if urlError.code == URLError.cancelled.rawValue {
                    completion(nil, AwesomeError.cancelled(error.localizedDescription))
                } else {
                    completion(nil, AwesomeError.unknown(error.localizedDescription))
                }
            }else{
                if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 401  {
                    completion(nil, AwesomeError.unauthorized)
                } else {
                    completion(data, nil)
                }
            }
        }
        requestManager.addRequest(to: url, task: dataTask)
        dataTask.resume()
    }
}
