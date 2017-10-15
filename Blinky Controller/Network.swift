//
//  Network.swift
//  Blinky Controller
//
//  Created by Evan Bernstein on 7/25/17.
//  Copyright © 2017 Evan Bernstein. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyUserDefaults
import SwiftMessages

class NetworkManager {
    public static let sharedInstance = NetworkManager()
    
    private var baseURL: String {
        return "http://" + Defaults[.ipAddress] + ":" + Defaults[.port] + "/"
    }
    
    public func getState(completion: @escaping ([Int]?, Double?, Bool?, Bool?, String?, [String]?, Double?, Double?) -> Void) {
        Alamofire.request(baseURL + "state").responseJSON { response in
            if let JSON = response.result.value as? [String: AnyObject] {
                let color = JSON["color"] as? [Int]
                let speed = JSON["speed"] as? Double
                let dynaColor = JSON["dyna_color"] as? Bool
                let isReverse = JSON["is_reverse"] as? Bool
                let command = JSON["command"] as? String
                let commands = JSON["commands"] as? [String]
                let minSpeed = JSON["min_speed"] as? Double
                let maxSpeed = JSON["max_speed"] as? Double
                
                completion(color, speed, dynaColor, isReverse, command, commands, minSpeed, maxSpeed)
            } else {
                completion(nil, nil, nil, nil, nil, nil, nil, nil)
            }
            
            switch response.result {
            case .success(_):
                NetworkErrorManager.connectionSucceeded()
            case .failure(let error):
                NetworkErrorManager.connectionFailed(kind: error.localizedDescription)
            }
        }
    }
    
    public func update(color: [Int]? = nil, speed: Double? = nil, dynaColor: Bool? = nil, isReverse: Bool? = nil, command: String? = nil, completion: (() -> ())? = nil) {
        var parameters = [String: Any]()
        if let color = color {
            parameters["color"] = color
        }
        if let speed = speed {
            parameters["speed"] = speed
        }
        if let dynaColor = dynaColor {
            parameters["dynamic_color"] = dynaColor
        }
        if let isReverse = isReverse {
            parameters["is_reverse"] = isReverse
        }
        if let command = command {
            parameters["command"] = command
        }
        
        Alamofire.request(baseURL + "update", method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: nil).responseJSON { response in
            completion?()
            switch response.result {
            case .success(_):
                NetworkErrorManager.connectionSucceeded()
            case .failure(let error):
                NetworkErrorManager.connectionFailed(kind: error.localizedDescription)
            }
        }
    }
    
    public func sendStop(completion: (() -> ())? = nil) {
        Alamofire.request(baseURL + "stop", method: .post, parameters: [:], encoding: JSONEncoding.default, headers: nil).responseJSON { response in
            completion?()
            switch response.result {
            case .success(_):
                NetworkErrorManager.connectionSucceeded()
            case .failure(let error):
                NetworkErrorManager.connectionFailed(kind: error.localizedDescription)
            }
        }
    }
    
    public func sendClear(completion: (() -> ())? = nil) {
        Alamofire.request(baseURL + "clear", method: .post, parameters: [:], encoding: JSONEncoding.default, headers: nil).responseJSON { response in
            completion?()
            switch response.result {
            case .success(_):
                NetworkErrorManager.connectionSucceeded()
            case .failure(let error):
                NetworkErrorManager.connectionFailed(kind: error.localizedDescription)
            }
        }
    }
    
    // https://www.reddit.com/r/swift/comments/4lhpqc/check_if_string_is_a_valid_ip_address/
    public class func isValidIPV4Address(_ ipAddress: String) -> Bool {
        let parts = ipAddress.components(separatedBy: ".")
        let nums = parts.flatMap { Int($0) }
        return nums.filter { $0 >= 0 && $0 < 256}.count == 4
    }
    
    public class func isValidPortNumber(_ portNumber: String) -> Bool {
        if let num = Int(portNumber), num < 65535 {
            return true
        }
        return false
    }
}

class NetworkErrorManager {
    public static let sharedInstance = NetworkErrorManager()
    
    private var lastConnectionSuccessful: Bool?
    
    private func connectionFailed(kind: String? = nil) {
        if lastConnectionSuccessful == nil || lastConnectionSuccessful! {
            lastConnectionSuccessful = false
            
            var message = "Failed to establish a connection to the server."
            if let kind = kind {
                message += " (\(kind))"
            }
            
            ErrorHandler.showError(iconText: "❌", title: "Connection Failed", body: message, theme: .error)
        }
    }

    private func connectionSucceeded(kind: String? = nil) {
        if lastConnectionSuccessful == nil || !lastConnectionSuccessful! /* !That feels gross! */ {
            lastConnectionSuccessful = true
            
            var message = "A connection to the server has been established."
            if let kind = kind {
                message += " (\(kind))"
            }
            
            ErrorHandler.showError(iconText: "✅", title: "Connection Successful", body: message, theme: .success)
        }
    }
    
    private func resetConnectionStatus() {
        lastConnectionSuccessful = nil
    }
    
    public class func connectionFailed(kind: String? = nil) {
        NetworkErrorManager.sharedInstance.connectionFailed(kind: kind)
    }
    
    public class func connectionSucceeded(kind: String? = nil) {
        NetworkErrorManager.sharedInstance.connectionSucceeded(kind: kind)
    }
    
    public class func resetConnectionStatus() {
        NetworkErrorManager.sharedInstance.resetConnectionStatus()
    }
}
