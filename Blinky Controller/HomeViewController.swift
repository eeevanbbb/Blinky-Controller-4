//
//  HomeViewController.swift
//  Blinky Controller
//
//  Created by Evan Bernstein on 7/25/17.
//  Copyright © 2017 Evan Bernstein. All rights reserved.
//

import UIKit
import Eureka
import SwiftyUserDefaults
import BusyNavigationBar

// https://stackoverflow.com/questions/38189640/swift-eureka-adding-text-value-to-buttonrow
public final class DetailedButtonRowOf<T: Equatable> : _ButtonRowOf<T>, RowType {
    public required init(tag: String?) {
        super.init(tag: tag)
        cellStyle = .value1
    }
}
public typealias DetailedButtonRow = DetailedButtonRowOf<String>

// https://stackoverflow.com/questions/44306449/adding-a-rule-to-a-custom-rule-in-eureka
struct RuleIPAddress<T: Equatable>: RuleType {
    public init() {}
    
    public var id: String?
    public var validationError: ValidationError = ValidationError(msg: "Invalid IP Address.")
    
    public func isValid(value: T?) -> ValidationError? {
        if let str = value as? String, NetworkManager.isValidIPV4Address(str) {
            return nil
        }
        return validationError
    }
}

struct RulePortNumber<T: Equatable>: RuleType {
    public init() {}
    
    public var id: String?
    public var validationError: ValidationError = ValidationError(msg: "Invalid Port Number.")
    
    public func isValid(value: T?) -> ValidationError? {
        if let str = value as? String, NetworkManager.isValidPortNumber(str) {
            return nil
        }
        return validationError
    }
}

class HomeViewController: FormViewController {
    
    var stateChange = false
    var userSliding = false

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        // Configure the nav title
        navigationItem.title = "Blinky Controller"
        
        // Build the menu
        form +++ Section("Control")
            <<< ButtonRow() {
                $0.title = "Clear"
                $0.onCellSelection { _, _ in
                    NetworkManager.sharedInstance.sendClear()
                    // Optimistically update the state
                    StateManager.sharedInstance.update(command: "None")
                }
            }
            <<< ButtonRow() {
                $0.title = "Freeze"
                $0.onCellSelection { _, _ in
                    NetworkManager.sharedInstance.sendStop()
                }
            }
            +++ Section("Customize")
            <<< PushRow<String>() {
                $0.tag = "PatternRow"
                $0.title = "Pattern"
                $0.options = StateManager.sharedInstance.availableCommands
                $0.value = StateManager.sharedInstance.command
                $0.selectorTitle = "Choose a pattern"
                $0.onChange { [weak self] row in
                    if self?.stateChange ?? false { return }
                    self?.startNavBarLoadingAnimation()
                    StateManager.sharedInstance.sendUpdate(command: row.value) {
                        self?.stopNavBarLoadingAnimation()
                    }
                }
            }
            <<< SliderRow() { row in
                row.tag = "SpeedRow"
                row.title = "Speed"
                row.value = Float(StateManager.sharedInstance.speed)
                row.cell.slider.minimumValue = Float(StateManager.sharedInstance.minSpeed)
                row.cell.slider.maximumValue = Float(StateManager.sharedInstance.maxSpeed)
                row.cell.slider.isContinuous = true
                row.cell.slider.onTouchDown.subscribe(on: self) {
                    self.userSliding = true
                }
                row.cell.slider.onTouchUpInside.subscribe(on: self) {
                    self.userSliding = false
                    if let speed = row.value {
                        self.startNavBarLoadingAnimation()
                        StateManager.sharedInstance.sendUpdate(speed: Double(speed)) {
                            self.stopNavBarLoadingAnimation()
                        }
                    }
                }
            }
            <<< DetailedButtonRow() { row in
                row.tag = "ColorRow"
                row.title = "Color"
                DispatchQueue.main.async {
                    row.cell.detailTextLabel?.text = StateManager.sharedInstance.color.hex(true)
                    row.cell.detailTextLabel?.textColor = StateManager.sharedInstance.color
                }
                row.presentationMode = PresentationMode.show(controllerProvider: ControllerProvider.callback {
                    return ColorViewController()
                    }, onDismiss: { vc in
                        let _ = vc.navigationController?.popViewController(animated: true)
                })
            }
            +++ Section("Advanced")
            <<< TextRow() { row in
                row.title = "IP Address"
                row.value = Defaults[.ipAddress]
                row.add(rule: RuleIPAddress())
                row.validationOptions = .validatesOnChange
                row.cell.textField.keyboardType = .decimalPad
                row.cell.textField.onEditingDidEnd.subscribe(on: self) {
                    if let ip = row.value {
                        Defaults[.ipAddress] = ip
                        NetworkErrorManager.resetConnectionStatus()
                        if !row.isValid {
                            ErrorHandler.showError(iconText: "📡", title: "Invalid IP Address", body: "The connection may not be successful.", theme: .warning)
                        }
                        DispatchQueue.main.async {
                            row.cell.textField.textColor = row.isValid ? UIColor.black : UIColor.red
                        }
                    }
                }
                row.onRowValidationChanged { cell, row in
                    DispatchQueue.main.async {
                        cell.textField.textColor = row.isValid ? UIColor.black : UIColor.red
                    }
                }
            }
            <<< TextRow() { row in
                row.title = "Port Number"
                row.value = Defaults[.port]
                row.add(rule: RulePortNumber())
                row.validationOptions = .validatesOnChange
                row.cell.textField.keyboardType = .numberPad
                row.cell.textField.onEditingDidEnd.subscribe(on: self) {
                    if let port = row.value {
                        Defaults[.port] = port
                        NetworkErrorManager.resetConnectionStatus()
                        if !row.isValid {
                            ErrorHandler.showError(iconText: "📡", title: "Invalid Port Number", body: "The connection may not be successful.", theme: .warning)

                        }
                        DispatchQueue.main.async {
                            row.cell.textField.textColor = row.isValid ? UIColor.black : UIColor.red
                        }
                    }
                }
                row.onRowValidationChanged { cell, row in
                    DispatchQueue.main.async {
                        cell.textField.textColor = row.isValid ? UIColor.black : UIColor.red
                    }
                }
            }
            <<< StepperRow() {
                $0.title = "Polling Interval"
                $0.value = Defaults[.pollingInterval]
                $0.cell.stepper.minimumValue = 1.0
                $0.cell.stepper.maximumValue = 10.0
                $0.cell.stepper.stepValue = 0.5
                $0.onChange { row in
                    TaskManager.sharedInstance.updatePollingInterval(row.cell.stepper.value)
                }
            }
        
        StateManager.sharedInstance.stateSignal.subscribe(on: self) {
            DispatchQueue.main.async {
                self.stateChange = true
                if let patternRow = self.form.rowBy(tag: "PatternRow") as? PushRow<String> {
                    patternRow.options = StateManager.sharedInstance.availableCommands
                    patternRow.value = StateManager.sharedInstance.command
                    patternRow.reload()
                }
                if let speedRow = self.form.rowBy(tag: "SpeedRow") as? SliderRow {
                    if !self.userSliding {
                        speedRow.value = Float(StateManager.sharedInstance.speed)
                        speedRow.cell.slider.minimumValue = Float(StateManager.sharedInstance.minSpeed)
                        speedRow.cell.slider.maximumValue = Float(StateManager.sharedInstance.maxSpeed)
                        speedRow.reload()
                    }
                }
                if let colorRow = self.form.rowBy(tag: "ColorRow") as? DetailedButtonRow {
                    colorRow.cell.detailTextLabel?.text = StateManager.sharedInstance.color.hex(true)
                    colorRow.cell.detailTextLabel?.textColor = StateManager.sharedInstance.color
                }
                self.stateChange = false
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func startNavBarLoadingAnimation() {
        DispatchQueue.main.async {
            self.navigationController?.navigationBar.start()
        }
    }
    
    func stopNavBarLoadingAnimation() {
        DispatchQueue.main.async {
            self.navigationController?.navigationBar.stop()
        }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
