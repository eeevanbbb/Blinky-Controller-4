//
//  Reachability.swift
//  Blinky Controller
//
//  Created by Evan Bernstein on 7/27/17.
//  Copyright © 2017 Evan Bernstein. All rights reserved.
//

import Foundation
import Signals

class ReachabilityManager {
    public static let sharedInstance = ReachabilityManager()
    
    private var internetReachability: Reachability!
    
    public enum InternetReachability {
        case NotReachable
        case ReachableViaWiFi
        case ReachableViaWWAN
    }
    
    public var reachabilitySignal = Signal<InternetReachability>()

    func beginObservingReachability() {
        NotificationCenter.default.addObserver(self, selector: #selector(ReachabilityManager.reachabilityChanged(notification:)), name: NSNotification.Name.reachabilityChanged, object: nil)
        
        internetReachability = Reachability.forInternetConnection()
        internetReachability.startNotifier()
        updateInterfaceWithReachability(reachability: internetReachability)
    }
    
    @objc public func reachabilityChanged(notification: NSNotification) {
        print("Reachability Changed")
        
        if let currentReachability = notification.object as? Reachability {
            updateInterfaceWithReachability(reachability: currentReachability)
        }
    }
    
    @objc public class func reachabilityChanged(notification: NSNotification) {
        ReachabilityManager.sharedInstance.reachabilityChanged(notification: notification)
    }
    
    func updateInterfaceWithReachability(reachability: Reachability) {
        let netStatus = reachability.currentReachabilityStatus()
        switch netStatus.rawValue {
        case 0:
            // Not reachable
            reachabilitySignal.fire(.NotReachable)
        case 1:
            // Reachable via WiFi
            reachabilitySignal.fire(.ReachableViaWiFi)
        case 2:
            // Reachable via WWAN
            reachabilitySignal.fire(.ReachableViaWWAN)
        default:
            break
        }
        
    }
}
