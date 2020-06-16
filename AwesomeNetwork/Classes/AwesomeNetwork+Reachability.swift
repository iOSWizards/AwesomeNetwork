//
//  AwesomeNetwork+Reachability.swift
//  AwesomeNetwork
//
//  Created by Evandro Harrison on 04/03/2019.
//

import Foundation

public enum AwesomeNetworkStateEvent: String {
    case connected
    case disconnected
}

extension AwesomeNetwork {
    
    // MARK: - lifecycle
    
    public func startNetworkStateNotifier() {
        reachability?.whenReachable = { reachability in
            // this is called on a background thread, but UI updates must
            // be on the main thread, like this:
            DispatchQueue.main.async {
                if reachability.connection != .none {
                    print("AwesomeNetwork: Reachable via \(reachability.connection.description)")
                    self.postNotification(with: .connected)
                }
            }
        }
        reachability?.whenUnreachable = { reachability in
            // this is called on a background thread, but UI updates must
            // be on the main thread, like this:
            DispatchQueue.main.async {
                print("AwesomeNetwork: Not reachable")
                self.postNotification(with: .disconnected)
            }
        }
        
        do {
            try reachability?.startNotifier()
        } catch {
            print("AwesomeNetwork: Unable to start notifier")
        }
    }
    
    public func stopNetworkStateNotifier() {
        reachability?.stopNotifier()
    }
    
    // MARK: - State Notifier
    
    public var isReachable: Bool {
        return reachability?.connection != .none
    }
    
    public var isWifiReachable: Bool {
        return reachability?.connection == .wifi
    }
    
    public var isCellularReachable: Bool {
        return reachability?.connection == .cellular
    }
    
    public func addObserver(_ observer: Any, selector: Selector, event: AwesomeNetworkStateEvent) {
        NotificationCenter.default.addObserver(observer, selector: selector, name: notificationName(with: event), object: nil)
    }
    
    public func removeObserver(_ observer: Any) {
        NotificationCenter.default.removeObserver(observer)
    }
    
    // MARK: - Helpers
    
    private func postNotification(with event: AwesomeNetworkStateEvent) {
        NotificationCenter.default.post(name: notificationName(with: event), object: nil)
    }
    
    private func notificationName(with event: AwesomeNetworkStateEvent) -> NSNotification.Name {
        return NSNotification.Name(rawValue: event.rawValue)
    }
    
}

extension UIView {
    public func listenToNetwork(onChange: @escaping (Bool) -> Void) {
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: AwesomeNetworkStateEvent.connected.rawValue), object: nil, queue: .main) { (_) in
            onChange(true)
        }
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: AwesomeNetworkStateEvent.disconnected.rawValue), object: nil, queue: .main) { (_) in
            onChange(false)
        }
    }
}
