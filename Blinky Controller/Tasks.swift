//
//  Tasks.swift
//  Blinky Controller
//
//  Created by Evan Bernstein on 7/25/17.
//  Copyright © 2017 Evan Bernstein. All rights reserved.
//

import Foundation
import SwiftyTimer
import SwiftyUserDefaults

class TaskManager {
    public static let sharedInstance = TaskManager()
    
    private var stateTimer: Timer?
    
    public func updatePollingInterval(_ newInterval: Double) {
        Defaults[.pollingInterval] = newInterval
        restartStateTimer()
    }
    
    private func restartStateTimer() {
        stateTimer?.invalidate()
        stateTimer = Timer.every(Defaults[.pollingInterval]) {
            StateManager.sharedInstance.refreshState()
        }
    }
    
    public func startTimers() {
        restartStateTimer()
    }
}
