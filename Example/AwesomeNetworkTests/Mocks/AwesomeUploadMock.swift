//
//  AwesomeUploadMock.swift
//  AwesomeNetwork_Example
//
//  Created by Evandro Harrison on 06/03/2019.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import Foundation
@testable import AwesomeNetwork

class AwesomeUploadMock: AwesomeUpload {
    
    var expectedData: Data?
    var expectedError: AwesomeError?
    
    init(expectedData: Data?, expectedError: AwesomeError?) {
        self.expectedData = expectedData
        self.expectedError = expectedError
    }
    
    override func upload(_ uploadData: Data?, to urlString: String?, headers: AwesomeRequesterHeader?, completion: @escaping AwesomeUploadResponse) {
        
        guard let url = urlString?.url() else {
            completion(self.expectedData, self.expectedError)
            return
        }
        
        let urlRequest = URLRequest.request(with: url)
        
        requestManager.addRequest(to: urlRequest, task: URLSessionDataTask())
        
        DispatchQueue.main.asyncAfter(deadline: .now()+1) {
            self.requestManager.removeRequest(to: urlRequest)
            
            completion(self.expectedData, self.expectedError)
        }
    }
}
