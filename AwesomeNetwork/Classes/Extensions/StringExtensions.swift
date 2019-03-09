//
//  StringExtensions.swift
//  AwesomeNetwork
//
//  Created by Evandro Harrison on 25/02/2019.
//

import Foundation

extension String {
    
    func url(withQueryItems queryItems: [URLQueryItem]? = nil) -> URL? {
        var urlComponents = URLComponents(string: self)
        
        if queryItems?.count ?? 0 > 0 {
            urlComponents?.queryItems = queryItems
        }
        
        return urlComponents?.url
    }
    
}
