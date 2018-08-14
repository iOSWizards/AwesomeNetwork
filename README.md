# AwesomeNetwork

[![CI Status](http://img.shields.io/travis/evandro@itsdayoff.com/AwesomeNetwork.svg?style=flat)](https://travis-ci.org/evandro@itsdayoff.com/AwesomeNetwork)
[![Version](https://img.shields.io/cocoapods/v/AwesomeNetwork.svg?style=flat)](http://cocoapods.org/pods/AwesomeNetwork)
[![License](https://img.shields.io/cocoapods/l/AwesomeNetwork.svg?style=flat)](http://cocoapods.org/pods/AwesomeNetwork)
[![Platform](https://img.shields.io/cocoapods/p/AwesomeNetwork.svg?style=flat)](http://cocoapods.org/pods/AwesomeNetwork)

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

- iOS 9 or Higher
- Swift 4

## Installation

AwesomeUIMagic is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'AwesomeNetwork', git: 'https://github.com/iOSWizards/AwesomeNetwork', tag: '0.1.6'
```
## Usage

Import with cocoapods and be happy. :)

### AppDelete.swift
- Start Notifier
```AwesomeNetwork.shared.startNetworkStateNotifier()```

- Stop Notifier
```AwesomeNetwork.shared.stopNetworkStateNotifier()```

### ViewController
- Add Observer : viewWillAppear
```AwesomeNetwork.shared.addObserver(self, selector: #selector(networkConnected), event: .connected)```

- Remove Observer: viewWillDisappear
```AwesomeNetwork.shared.removeObserver(self)```

## License

AwesomeNetwork is available under the MIT license. See the LICENSE file for more info.
