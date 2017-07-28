//
//  Settings.swift
//  Blinky Controller
//
//  Created by Evan Bernstein on 7/25/17.
//  Copyright © 2017 Evan Bernstein. All rights reserved.
//

import Foundation
import SwiftyUserDefaults

extension DefaultsKeys {
    static let ipAddress = DefaultsKey<String>("ipAddress")
    static let port = DefaultsKey<String>("port")
    static let pollingInterval = DefaultsKey<Double>("pollingInterval")
    static let showAdvancedSettings = DefaultsKey<Bool>("showAdvancedSettings")
}

extension UserDefaults {
    func registerDefault<T: RawRepresentable>(_ key: DefaultsKey<T>, _ value: T) {
        Defaults.register(defaults: [ key._key: value.rawValue ])
    }
    
    func registerDefault<T>(_ key: DefaultsKey<T>, _ value: T) {
        Defaults.register(defaults: [ key._key: value ])
    }
}
