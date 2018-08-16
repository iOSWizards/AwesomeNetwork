//
//  AwesomeNetwork.swift
//  MVA Home
//
//  Created by Antonio da Silva on 20/02/2017.
//  Copyright © 2017 Mindvalley. All rights reserved.
//

import Foundation
import Reachability
import AwesomeConstants

public enum NetworkStateEvent: String {
    case connected
    case disconnected
}

public struct AwesomeNetwork {

    public static var shared = AwesomeNetwork()
    
    private let reachability = Reachability()
    
    // MARK: - AwesomeNetwork lifecycle
    
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
    
    public func isWifiConnected(viewController: UIViewController,
                                noConnectionMessage: String,
                                okButtonTitle: String = "Ok",
                                onPress: (() -> Void)? = nil) -> Bool {
        
        if reachability?.connection == .wifi {
            return true
        } else {
            viewController.showAlert(message: noConnectionMessage, completion: {
            }, buttons: (UIAlertActionStyle.default, okButtonTitle, onPress))
            
        }
        
        return false
    }
    
    // MARK: - State Notifier
    
    /*
     * True if Internet connection is reachable either by WiFi or Cellular and false in any other case.
     */
    public func isReachable(viewController: UIViewController,
                            noConnectionMessage: String,
                            okButtonTitle: String = "Ok",
                            onPress: (() -> Void)? = nil) -> Bool {
        if isReachable {
            return true
        }
        
        viewController.showAlert(message: noConnectionMessage, completion: {
        }, buttons: (UIAlertActionStyle.default, okButtonTitle, onPress))
        
        return false
    }
    
    public var isReachable: Bool {
        return reachability?.connection != .none
    }
    
    public var isWifiReachable: Bool {
        return reachability?.connection == .wifi
    }
    
    public var isCellularReachable: Bool {
        return reachability?.connection == .cellular
    }
    
    public func addObserver(_ observer: Any, selector: Selector, event: NetworkStateEvent) {
        NotificationCenter.default.addObserver(observer, selector: selector, name: notificationName(with: event), object: nil)
    }
    
    public func removeObserver(_ observer: Any) {
        NotificationCenter.default.removeObserver(observer)
    }
    
    // MARK: - Helpers
    
    private func postNotification(with event: NetworkStateEvent) {
        NotificationCenter.default.post(name: notificationName(with: event), object: nil)
    }
    
    private func notificationName(with event: NetworkStateEvent) -> NSNotification.Name {
        return NSNotification.Name(rawValue: event.rawValue)
    }
   
    public static func startNetworkStateNotifier() {
        shared.startNetworkStateNotifier()
    }
    
    public static func stopNetworkStateNotifier() {
        shared.stopNetworkStateNotifier()
    }
    
}

extension UIView {
    public func listenToNetwork(onChange: @escaping (Bool) -> Void) {
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: NetworkStateEvent.connected.rawValue), object: nil, queue: .main) { (_) in
            onChange(true)
        }
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: NetworkStateEvent.disconnected.rawValue), object: nil, queue: .main) { (_) in
            onChange(false)
        }
    }
}

extension UIViewController {
    
    func showAlert(withTitle title: String? = nil, message: String?,  completion: (() -> ())? = nil, buttons: (UIAlertActionStyle, String, (() -> ())?)...) {
        
        guard let message = message, message.count > 0 else {
            return
        }
        
        if #available(iOS 8.0, *){
            let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alertController.modalPresentationStyle = isPad ? .popover : .currentContext
            
            for button in buttons {
                alertController.addAction(UIAlertAction(title: button.1, style: button.0) { (_: UIAlertAction!) in
                    if let completion = completion { completion() }
                    if let actionBlock = button.2 { actionBlock() }
                })
            }
            self.present(alertController, animated: true, completion: nil)
        }else {
            // Handle prior iOS Versions
            
        }
    }
    
}
