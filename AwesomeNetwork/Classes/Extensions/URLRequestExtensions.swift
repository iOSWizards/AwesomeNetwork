//
//  URLRequestExtensions.swift
//  AwesomeNetwork
//
//  Created by Evandro Harrison on 06/03/2019.
//

import Foundation

extension URLRequest {
    
    public static func request(with url: URL,
                               method: URLMethod? = .GET,
                               bodyData: Data? = nil,
                               headers: [String: String]? = nil,
                               timeoutAfter timeout: TimeInterval = 15) -> URLRequest {
        let urlRequest = NSMutableURLRequest(url: url)
        
        if let method = method {
            urlRequest.httpMethod = method.rawValue
        }
        
        if let bodyData = bodyData {
            urlRequest.httpBody = bodyData
        }
        
        if let headers = headers {
            for key in headers.keys {
                urlRequest.addValue(headers[key] ?? "", forHTTPHeaderField: key)
            }
        }
        
        if timeout > 0 {
            urlRequest.timeoutInterval = timeout
        }
        
        return urlRequest as URLRequest
    }
    
}
