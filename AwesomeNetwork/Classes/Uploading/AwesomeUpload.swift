//
//  AwesomeUpload.swift
//  AwesomeNetwork
//
//  Created by Evandro Harrison on 06/03/2019.
//

import Foundation

public typealias AwesomeUploadResponse = (Data?, AwesomeError?) -> Void

public class AwesomeUpload: NSObject {
    
    public static var shared: AwesomeUpload = AwesomeUpload()
    
    var requestManager: AwesomeRequestManager = AwesomeRequestManager()
    
    func upload(_ uploadData: Data?,
                to urlString: String?,
                headers: AwesomeRequesterHeader? = nil,
                completion: @escaping AwesomeUploadResponse) {
        guard let uploadData = uploadData else {
            completion(nil, AwesomeError.invalidData)
            return
        }
        
        guard let url = urlString?.url() else {
            completion(nil, AwesomeError.invalidUrl)
            return
        }
        
        let urlRequest = URLRequest.request(with: url,
                                            method: .POST,
                                            headers: headers)
        
        let task = URLSession.shared.uploadTask(with: urlRequest, from: uploadData) { [weak self] data, response, error in
            self?.requestManager.removeRequest(to: url)
            
            if let error = error {
                completion(nil, AwesomeError.uploadFailed(error.localizedDescription))
                return
            }
            
            guard let response = response as? HTTPURLResponse,
                (200...299).contains(response.statusCode) else {
                    completion(nil, AwesomeError.uploadFailed("server error"))
                    return
            }
            
            if let data = data {
                completion(data, nil)
            }
        }
        requestManager.addRequest(to: url, task: task)
        task.resume()
    }
    
}
