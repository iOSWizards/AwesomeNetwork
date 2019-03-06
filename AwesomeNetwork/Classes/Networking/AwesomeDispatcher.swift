//
//  AwesomeDispatcher.swift
//  AwesomeNetwork
//
//  Created by Evandro Harrison on 25/02/2019.
//

import Foundation

class AwesomeDispatcher {
    
    public static var shared = AwesomeDispatcher()
    
    let defaultQueue: DispatchQueue = .global(qos: .default)
    let dispatchSemaphore: DispatchSemaphore = DispatchSemaphore(value: 1)
    var hasGreenLights: Bool = false
    var timeout: TimeInterval? = 5
    
    func releaseSemaphore() {
        hasGreenLights = true
        dispatchSemaphore.signal()
    }
    
    private func wait() {
        if let timeout = self.timeout {
            _ = self.dispatchSemaphore.wait(timeout: .now() + timeout)
        } else {
            _ = self.dispatchSemaphore.wait()
        }
    }
    
    func executeBlock(signalNext: Bool = true,
                      queue: DispatchQueue? = nil,
                      block: @escaping () -> Swift.Void) {
        let queue = queue ?? defaultQueue
        
        if hasGreenLights {
            queue.async(execute: block)
        } else {
            queue.async {
                _ = self.wait()
                queue.async(execute: block)
                
                if signalNext {
                    self.dispatchSemaphore.signal()
                }
            }
        }
    }
}
