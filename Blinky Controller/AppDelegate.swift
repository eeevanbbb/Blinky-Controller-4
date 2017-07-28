//
//  AppDelegate.swift
//  Blinky Controller
//
//  Created by Evan Bernstein on 7/25/17.
//  Copyright © 2017 Evan Bernstein. All rights reserved.
//

import UIKit
import SwiftyUserDefaults

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        // Build the window
        let homeVC = HomeViewController()
        let navController = UINavigationController(rootViewController: homeVC)
        window = UIWindow(frame: UIScreen.main.bounds)
        if let window = window {
            window.backgroundColor = UIColor.white
            window.rootViewController = navController
            window.makeKeyAndVisible()
        }
        
        // Register defaults settings
        Defaults.registerDefault(.ipAddress, "192.168.1.85")
        Defaults.registerDefault(.port, "9001")
        Defaults.registerDefault(.pollingInterval, 2.0)
        Defaults.registerDefault(.showAdvancedSettings, false)
        
        // Get initial state
        StateManager.sharedInstance.refreshState()
        
        // Start timers
        TaskManager.sharedInstance.startTimers()
        
        // Monitor reachability
        ReachabilityManager.sharedInstance.reachabilitySignal.subscribe(on: self) { reachability in
            if reachability != .ReachableViaWiFi {
                ErrorHandler.showWiFiMessage()
            } else {
                ErrorHandler.hideWiFiMessage()
            }
        }
        ReachabilityManager.sharedInstance.beginObservingReachability()
                
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

