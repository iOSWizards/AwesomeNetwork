//
//  AwesomeNetwork.swift
//  MVA Home
//
//  Created by Antonio da Silva on 20/02/2017.
//  Copyright © 2017 Mindvalley. All rights reserved.
//

import Foundation
import ReachabilitySwift

public enum NetworkStateEvent: String {
    case connected = "connected"
    case disconnected = "disconnected"
}

public struct AwesomeNetwork {

    public static var shared: AwesomeNetwork?
    private let reachability = Reachability()
    
    public static func startNetworkStateNotifier() {
        shared = AwesomeNetwork()
        shared?.startNetworkStateNotifier()
    }

    // MARK: - AwesomeNetwork lifecycle

    private init() {
        print("AwesomeNetwork: init()")
    }

    public func startNetworkStateNotifier() {
        reachability?.whenReachable = { reachability in
            // this is called on a background thread, but UI updates must
            // be on the main thread, like this:
            DispatchQueue.main.async {
                if reachability.isReachable {
                    print("AwesomeNetwork: Reachable via \(reachability.currentReachabilityString)")
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
        if isReachable() {
            if reachability?.isReachableViaWiFi ?? false {
                return true
            }
        }

        viewController.showAlert(message: noConnectionMessage, completion: {
        }, buttons: (UIAlertActionStyle.default, okButtonTitle, onPress))

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
        if isReachable() {
            return true
        }

        viewController.showAlert(message: noConnectionMessage, completion: {
        }, buttons: (UIAlertActionStyle.default, okButtonTitle, onPress))

        return false
    }
    
    public func isReachable() -> Bool {
        return reachability?.isReachable ?? false
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
}
