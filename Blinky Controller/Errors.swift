//
//  Errors.swift
//  Blinky Controller
//
//  Created by Evan Bernstein on 7/27/17.
//  Copyright © 2017 Evan Bernstein. All rights reserved.
//

import Foundation
import SwiftMessages

class ErrorHandler {
    private static let wifiMessageId = "WiFiMessage"
    
    public class func showError(iconText: String? = nil, title: String? = nil, body: String? = nil, theme: Theme, presentationStyle: SwiftMessages.PresentationStyle = .top) {
        var config = SwiftMessages.Config()
        config.presentationStyle = presentationStyle
        config.duration = .seconds(seconds: 5)
        
        let view = MessageView.viewFromNib(layout: .CardView)
        view.configureTheme(theme)
        view.configureDropShadow()
        view.configureContent(title: title, body: body, iconImage: nil, iconText: iconText, buttonImage: nil, buttonTitle: nil, buttonTapHandler: nil)
        DispatchQueue.main.async {
            SwiftMessages.show(config: config, view: view)
        }
    }
    
    public class func showWiFiMessage() {
        var config = SwiftMessages.Config()
        config.presentationStyle = .top
        config.duration = .forever
        
        let view = MessageView.viewFromNib(layout: .CardView)
        view.configureTheme(.warning)
        view.configureDropShadow()
        view.configureContent(title: "Can't Connect via WiFi", body: "Please make sure your WiFi is turned on and connected.", iconImage: nil, iconText: "📲", buttonImage: nil, buttonTitle: "Settings", buttonTapHandler: { _ in
            if let url = URL(string: "App-Prefs:root=WIFI") {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        })
        view.id = wifiMessageId
        DispatchQueue.main.async {
            self.hideWiFiMessage()
            SwiftMessages.show(config: config, view: view)
        }
    }
    
    public class func hideWiFiMessage() {
        SwiftMessages.hide(id: wifiMessageId)
    }
}
