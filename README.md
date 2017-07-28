# Blinky Controller

A native iOS app for controlling a LAN-hosted [Blinky Server](https://github.com/eeevanbbb/BlinkyServer). This is version 4.0 of the app.

## Requirements

Xcode 8 and iOS 10.

## Installation

Clone the repo, open the .xcworkspace file, and `Build` and `Run` the app.

## Usage

To use the app with your own [Blinky Server](https://github.com/eeevanbbb/BlinkyServer), flip the switch for `Advanced Settings` and configure the `IP address` and `Port number` to match your setup. (NOTE: While one can, in theory, control a Blinky Server over WAN, it has not been tested.)

## Features

### Control

`Clear` and `Freeze` the lights.

### Customize

Change the `Pattern`, `Speed`, or `Color` using the controls provided. In the `Color` page, there is also a switch for toggling `Dynamic Color`, which will cycle through the color spectrum automatically.

### Advanced Settings

Toggle the switch to `Show Advanced Settings`. Here, a user can change the `IP Address` and `Port Number` the app tries to communicate with. There is also a stepper for controlling the `Polling Interval`, i.e. the frequency with which the app makes requests to the server.

## Libraries Used

Big thanks to the following `Cocoapods` used in this app:

- [Hue](https://github.com/hyperoslo/Hue)
- [Chroma Color Picker](https://github.com/joncardasis/ChromaColorPicker)
- [Swifty Timer](https://github.com/radex/SwiftyTimer)
- [Swifty User Defaults](https://github.com/radex/SwiftyUserDefaults#installation)
- [Eureka](https://github.com/xmartlabs/Eureka)
- [Signals](https://github.com/artman/Signals)
- [Chameleon](https://github.com/ViccAlexander/Chameleon)
- [SwiftMessages](https://github.com/SwiftKickMobile/SwiftMessages)
- [IHKeyboardAvoiding](https://github.com/IdleHandsApps/IHKeyboardAvoiding)
- [Alamofire](https://github.com/Alamofire/Alamofire)
- [BusyNavigationBar](https://github.com/gmertk/BusyNavigationBar)

Please note that some of these pods have been modified in this project, so reinstalling them will cause the project not to build.

## Development

Feel free to contribute to the development of this app by submitting a pull request!
