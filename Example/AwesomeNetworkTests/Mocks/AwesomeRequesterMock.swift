//
//  AwesomeRequesterMock.swift
//  AwesomeNetwork_Tests
//
//  Created by Evandro Harrison on 28/02/2019.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import Foundation
@testable import AwesomeNetwork

class AwesomeRequesterMock: AwesomeRequester {
    
    var expectedData: Data?
    var expectedError: AwesomeError?
    
    init(expectedData: Data?, expectedError: AwesomeError?) {
        self.expectedData = expectedData
        self.expectedError = expectedError
    }
    
    override func performRequest(_ urlRequest: URLRequest, completion: @escaping AwesomeDataResponse) {
        AwesomeNetwork.shared.requester?.requestManager.addRequest(to: urlRequest.url, task: URLSessionDataTask())
        
        DispatchQueue.main.asyncAfter(deadline: .now()+1) {
            AwesomeNetwork.shared.requester?.requestManager.removeRequest(to: urlRequest.url)
            
            completion(self.expectedData, self.expectedError)
        }
    }
}
