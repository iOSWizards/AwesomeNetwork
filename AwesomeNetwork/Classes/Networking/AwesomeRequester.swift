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

public typealias AwesomeDataResponse = (Result<Data, AwesomeError>) -> Void
public typealias AwesomeRetryDataResponse = (Result<Data, AwesomeError>, Int) -> Void
public typealias AwesomeRequesterHeader = [String: String]

public class AwesomeRequester: NSObject {
    
    var requestManager: AwesomeRequestManager = AwesomeRequestManager()
    var useSemaphore: Bool = false
    
    init(useSemaphore: Bool) {
        self.useSemaphore = useSemaphore
    }
    
    /// Retry fetching data as long as it's not a successful response
    ///
    /// - Parameters:
    ///   - request: Parameters for request
    ///   - retry count: Choice to use or not semaphore
    ///   - completion: Returns fetched NSData in a block
    /// - Returns: URLSessionDataTask
    func performRequestRetrying(_ request: AwesomeRequestProtocol,
                                retryCount: Int,
                                intermediate: AwesomeRetryDataResponse? = nil,
                                completion:@escaping AwesomeDataResponse) {
        performRequest(request) { (result) in
            intermediate?(result, retryCount)
            
            if !request.isSuccessResponse(try? result.get()), retryCount > 0 {
                // adds a small timeout between calls
                request.queue.asyncAfter(deadline: .now()+AwesomeNetwork.shared.retryTimeout, execute: {
                    self.performRequestRetrying(request,
                                                retryCount: retryCount-1,
                                                intermediate: intermediate,
                                                completion: completion)
                })
            } else {
                completion(result)
            }
        }
    }
    
    /// Fetch data from URL with NSUrlSession
    ///
    /// - Parameters:
    ///   - request: Parameters for request
    ///   - completion: Returns fetched NSData in a block
    /// - Returns: URLSessionDataTask
    func performRequest(_ request: AwesomeRequestProtocol,
                        completion:@escaping AwesomeDataResponse) {
        guard let urlRequest = request.urlRequest else {
            return
        }
        
        if useSemaphore {
            AwesomeDispatcher.shared.executeBlock(queue: request.queue) { [weak self] in
                self?.performRequest(urlRequest, cancelPrevious: request.cancelPreviousRequest, completion: completion)
            }
        } else {
            performRequest(urlRequest, cancelPrevious: request.cancelPreviousRequest, completion: completion)
        }
        
    }
    
    /// Fetch data from URL with NSUrlSession
    ///
    /// - Parameters:
    ///   - urlRequest: Url Request to fetch data form
    ///   - completion: Returns fetched NSData in a block
    /// - Returns: URLSessionDataTask
    internal func performRequest(_ urlRequest: URLRequest,
                                 cancelPrevious: Bool = false,
                                 completion:@escaping AwesomeDataResponse) {
        let session = URLSession.shared
        let dataTask = session.dataTask(with: urlRequest) { (data, response, error) in
            self.requestManager.removeRequest(to: urlRequest)
            
            if let error = error {
                let urlError = error as NSError
                switch urlError.code {
                case NSURLErrorTimedOut:
                    completion(.failure(.timeOut(error.localizedDescription)))
                case NSURLErrorNotConnectedToInternet:
                    completion(.failure(.noConnection(error.localizedDescription)))
                case URLError.cancelled.rawValue:
                    completion(.failure(.cancelled(error.localizedDescription)))
                default:
                    completion(.failure(.unknown(error.localizedDescription)))
                }
            } else {
                if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 401  {
                    completion(.failure(.unauthorized))
                } else if let data = data {
                    completion(.success(data))
                } else {
                    completion(.failure(.invalidData))
                }
            }
        }
        requestManager.addRequest(to: urlRequest, task: dataTask, cancelPrevious: cancelPrevious)
        dataTask.resume()
    }
}
