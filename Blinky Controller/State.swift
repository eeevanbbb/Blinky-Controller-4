//
//  State.swift
//  Blinky Controller
//
//  Created by Evan Bernstein on 7/25/17.
//  Copyright © 2017 Evan Bernstein. All rights reserved.
//

import Foundation
import UIKit
import Hue
import Signals

private struct State {
    var color: [Int] = [0,0,0]
    var speed: Double = 0.0
    var dynaColor: Bool = false
    var isReverse: Bool = false
    var command: String = "None"
    
    var availableCommands: [String] = []
    var minSpeed: Double = 0 // DEFAULT
    var maxSpeed: Double = 60 // DEFAULT
  
    // Not supported
//    var bpm: Int = 0
//    var patternParameters = [String: String]()
}

extension UIColor {
    var rgbIntColor: [Int] {
        return [redComponent, greenComponent, blueComponent].map { Int($0 * 255) }
    }
    
    convenience init(red: Int, green: Int, blue: Int) {
        self.init(red: CGFloat(red) / 255, green: CGFloat(green) / 255, blue: CGFloat(blue) / 255, alpha: 1)
    }
    
    convenience init(_ rgbIntColor: [Int]) {
        if rgbIntColor.count != 3 {
            self.init()
        } else {
            self.init(red: rgbIntColor[0], green: rgbIntColor[1], blue: rgbIntColor[2])
        }
    }
}

class StateManager {
    public static let sharedInstance = StateManager()
    
    private var state = State() // TODO: Load from user defaults?
    
    public var stateSignal = Signal<Void>()
    public func update(color: [Int]? = nil, uiColor: UIColor? = nil, speed: Double? = nil, dynaColor: Bool? = nil, isReverse: Bool? = nil, command: String? = nil) {
        if let color = color {
            state.color = color
        }
        if let uiColor = uiColor {
            state.color = uiColor.rgbIntColor
        }
        if let speed = speed {
            state.speed = speed
        }
        if let dynaColor = dynaColor {
            state.dynaColor = dynaColor
        }
        if let isReverse = isReverse {
            state.isReverse = isReverse
        }
        if let command = command {
            state.command = command
        }
        
        self.stateSignal.fire()
    }

    public var color: UIColor {
        return UIColor(state.color)
    }
    
    public var speed: Double {
        return state.speed
    }
    
    public var dynaColor: Bool {
        return state.dynaColor
    }
    
    public var isReverse: Bool {
        return state.isReverse
    }
    
    public var command: String {
        return state.command
    }
    
    public var availableCommands: [String] {
        return state.availableCommands
    }
    
    public var minSpeed: Double {
        return state.minSpeed
    }
    
    public var maxSpeed: Double {
        return state.maxSpeed
    }
    
    public func refreshState() {
        NetworkManager.sharedInstance.getState { color, speed, dynaColor, isReverse, command, commands, minSpeed, maxSpeed  in
            self.update(color: color, speed: speed, dynaColor: dynaColor, isReverse: isReverse, command: command)
            if let commands = commands {
                self.state.availableCommands = commands
            }
            if let minSpeed = minSpeed {
                self.state.minSpeed = minSpeed
            }
            if let maxSpeed = maxSpeed {
                self.state.maxSpeed = maxSpeed
            }
        }
    }
    
    public func sendUpdate(color: [Int]? = nil, uiColor: UIColor? = nil, speed: Double? = nil, dynaColor: Bool? = nil, isReverse: Bool? = nil, command: String? = nil, completion: (() -> ())? = nil) {
        NetworkManager.sharedInstance.update(color: color ?? uiColor?.rgbIntColor, speed: speed, dynaColor: dynaColor, isReverse: isReverse, command: command) {
            // Fail gracefully?
            completion?()
        }
        
        // Optimistically update the UI
        update(color: color, uiColor: uiColor, speed: speed, dynaColor: dynaColor, isReverse: isReverse, command: command)
    }
}
