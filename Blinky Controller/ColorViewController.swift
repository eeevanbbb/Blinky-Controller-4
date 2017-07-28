//
//  ColorViewController.swift
//  Blinky Controller
//
//  Created by Evan Bernstein on 7/26/17.
//  Copyright © 2017 Evan Bernstein. All rights reserved.
//

import UIKit
import ChromaColorPicker
import ChameleonFramework
import SwiftMessages
import IHKeyboardAvoiding
import BusyNavigationBar

class ColorViewController: UIViewController, UITextFieldDelegate {
    
    var userChanging = false
    var colorPicker = ChromaColorPicker()
    var dynamicColorSwitch = UISwitch()
    var dynamicColorLabel = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        navigationItem.title = "Choose Color"
        
        // Set up the color picker
        
        colorPicker.addButton.isHidden = true
        layoutChromaColorPicker()
        view.addSubview(colorPicker)
        
        colorPicker.hexField.delegate = self
        colorPicker.hexField.returnKeyType = .done
        colorPicker.hexField.autocapitalizationType = .allCharacters
        
        colorPicker.adjustToColor(StateManager.sharedInstance.color, animated: false)
        colorPicker.hexField.textColor = colorPicker.currentColor
        let contrastColor = ContrastColorOf(colorPicker.currentColor, returnFlat: false).alpha(0.2)
        view.backgroundColor = contrastColor
        colorPicker.handleLine.fillColor = ContrastColorOf(contrastColor, returnFlat: false).alpha(0.2).cgColor
        colorPicker.handleLine.strokeColor = ContrastColorOf(contrastColor, returnFlat: false).alpha(0.2).cgColor
        
        StateManager.sharedInstance.stateSignal.subscribe(on: self) {
            if !self.userChanging {
                self.colorPicker.adjustToColor(StateManager.sharedInstance.color)
                
                self.dynamicColorSwitch.isOn = StateManager.sharedInstance.dynaColor
                self.colorPicker.isEnabled = !self.dynamicColorSwitch.isOn
                self.colorPicker.alpha = self.colorPicker.isEnabled ? 1.0 : 0.3
            }
        }
        
        colorPicker.onTouchDown.subscribe(on: self) {
            self.userChanging = true
        }
        colorPicker.shadeSlider.onTouchDown.subscribe(on: self) {
            self.userChanging = true
        }
        
        colorPicker.onTouchUpInside.subscribe(on: self) {
            self.startNavBarLoadingAnimation(color: self.colorPicker.currentColor)
            StateManager.sharedInstance.sendUpdate(uiColor: self.colorPicker.currentColor) {
                self.stopNavBarLoadingAnimation()
            }
            self.userChanging = self.colorPicker.hexField.isEditing
        }
        colorPicker.shadeSlider.onTouchUpInside.subscribe(on: self) {
            self.startNavBarLoadingAnimation(color: self.colorPicker.currentColor)
            StateManager.sharedInstance.sendUpdate(uiColor: self.colorPicker.currentColor) {
                self.stopNavBarLoadingAnimation()
            }
            self.userChanging = self.colorPicker.hexField.isEditing
        }
        
        colorPicker.onValueChanged.subscribe(on: self) {
            self.colorPicker.hexField.textColor = self.colorPicker.currentColor
            let contrastColor = ContrastColorOf(self.colorPicker.currentColor, returnFlat: false).alpha(0.2)
            if self.view.backgroundColor != contrastColor {
                UIView.animate(withDuration: 0.2) {
                    self.view.backgroundColor = contrastColor
                    self.colorPicker.handleLine.fillColor = ContrastColorOf(contrastColor, returnFlat: false).alpha(0.2).cgColor
                    self.colorPicker.handleLine.strokeColor = ContrastColorOf(contrastColor, returnFlat: false).alpha(0.2).cgColor
                }
            }
        }
        
        // Set up the dyanmic color switch
        layoutDynamicColorSwitch()
        view.addSubview(dynamicColorSwitch)
        
        dynamicColorSwitch.isOn = StateManager.sharedInstance.dynaColor
        colorPicker.isEnabled = !dynamicColorSwitch.isOn
        colorPicker.alpha = colorPicker.isEnabled ? 1.0 : 0.3
        dynamicColorSwitch.onValueChanged.subscribe(on: self) {
            self.colorPicker.isEnabled = !self.dynamicColorSwitch.isOn
            self.colorPicker.alpha = self.colorPicker.isEnabled ? 1.0 : 0.3
            self.startNavBarLoadingAnimation(color: StateManager.sharedInstance.color)
            StateManager.sharedInstance.sendUpdate(dynaColor: self.dynamicColorSwitch.isOn) {
                self.stopNavBarLoadingAnimation()
            }
            if self.dynamicColorSwitch.isOn {
                self.colorPicker.hexField.resignFirstResponder()
            }
        }
        
        // Set up the dynamic color label
        dynamicColorLabel.text = "Dynamic Color"
        dynamicColorLabel.textColor = UIColor.black
        dynamicColorLabel.sizeToFit()
        view.addSubview(dynamicColorLabel)
        
        layoutDynamicColorLabel()
        
        // Add keyboard hiding gesture recognizer
        addKeyboardHidingGestureRecognizer()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        KeyboardAvoiding.avoidingView = colorPicker.hexField
    }
    
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        coordinator.animate(alongsideTransition: { _ in
            self.layoutChromaColorPicker()
            self.layoutDynamicColorSwitch()
            self.layoutDynamicColorLabel()
        }, completion: nil)
    }
    
    func layoutChromaColorPicker() {
        let size = min(view.frame.width, view.frame.height) * 0.75
        colorPicker.frame = CGRect(x: 0, y: 0, width: size, height: size)
        colorPicker.center = view.center
        colorPicker.frame.origin.y = 50
        
        if let navHeight = navigationController?.navigationBar.frame.size.height {
            colorPicker.frame.origin.y = navHeight + 10
        }
        
        colorPicker.layout()
    }
    
    func layoutDynamicColorSwitch() {
        dynamicColorSwitch.center.x = view.center.x + view.frame.size.width / 4
        dynamicColorSwitch.frame.origin.y = colorPicker.frame.origin.y + colorPicker.frame.size.height + 10
    }
    
    func layoutDynamicColorLabel() {
        dynamicColorLabel.center.x = view.center.x - view.frame.size.width / 4
        dynamicColorLabel.center.y = dynamicColorSwitch.center.y
    }
    
    
    // MARK: - Loading bar
    
    func startNavBarLoadingAnimation(color: UIColor = UIColor.gray) {
        let options = BusyNavigationBarOptions()
        options.color = color
        
        DispatchQueue.main.async {
            self.navigationController?.navigationBar.start(options)
        }
    }
    
    func stopNavBarLoadingAnimation() {
        DispatchQueue.main.async {
            self.navigationController?.navigationBar.stop()
        }
    }
    
    
    // MARK: - UITextFieldDelegate
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        // https://stackoverflow.com/questions/24015848/using-stringbyreplacingcharactersinrange-in-swift
        let result = (textField.text as NSString?)?.replacingCharacters(in: range, with: string) ?? string
        
        if result.length >= 1 && result.length <= 7 && result.characters.first == "#" {
            if result.substring(from: 1).containsOnlyHexidecimalCharacters() {
                return true
            } else if result.uppercased().substring(from: 1).containsOnlyHexidecimalCharacters() {
                textField.text = (textField.text as NSString?)?.replacingCharacters(in: range, with: string.uppercased())
                return false
            }
        }
        
        return false
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        userChanging = true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        userChanging = false
        
        // Verify color
        if let text = textField.text, text.isValidHexColor() {
            let color = UIColor(hex: text)
            colorPicker.adjustToColor(color , animated: true)
            startNavBarLoadingAnimation(color: color)
            StateManager.sharedInstance.sendUpdate(uiColor: color) {
                self.stopNavBarLoadingAnimation()
            }
        } else {
            ErrorHandler.showError(iconText: "🖍", title: "Invalid Hex Color", body: "The hex code for the color was not valid.", theme: .warning)
            
            colorPicker.updateHexField()
        }        
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

extension String {
    var length: Int {
        return characters.count
    }
    
    func substring(from: Int) -> String {
        return substring(from: index(startIndex, offsetBy: from))
    }
    
    func containsOnlyHexidecimalCharacters() -> Bool {
        return characters.filter { "0123456789ABCDEF".characters.contains($0) }.count == length
    }
    
    func isValidHexColor() -> Bool {
        let hex = hasPrefix("#") ? String(characters.dropFirst()) : self
        guard hex.length == 6 else { return false }
        return hex.containsOnlyHexidecimalCharacters()
    }
}

// https://stackoverflow.com/questions/32281651/how-to-dismiss-keyboard-when-touching-anywhere-outside-uitextfield-in-swift
extension UIViewController
{
    func addKeyboardHidingGestureRecognizer()
    {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(
            target: self,
            action: #selector(UIViewController.dismissKeyboard))
        
        view.addGestureRecognizer(tap)
    }
    
    func dismissKeyboard()
    {
        view.endEditing(true)
    }
}
