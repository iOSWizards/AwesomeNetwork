# AwesomeNetwork

## Example

To run the example project:
1) clone the repo.
2) run `pod install` from the **Example** directory first.
3) open **AwesomeNetwork.xcworkspace** from **Example** directory.

## Requirements

- iOS 10 or Higher
- Swift 4.2

### Dependencies

The dependencies will get auto imported.

- 'RealmSwift', '~> 3.9.0'

## Installation

AwesomeCore is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'AwesomeNetwork', git: 'https://github.com/iOSWizards/AwesomeNetwork', tag: '0.2.0'
```

### For Objective-C Project

1) Open App Project
2) In Project Navigator, select **Pods**
3) Select **AwesomeNetwork** from Targets and navigate to **Build Settings**
4) Search for **"Require Only App-Extension-Safe API"** and set it to **"No"**

## Usage

### Swift

Accessing public files and functions:
```swift
import AwesomeNetwork
```

Run the following when app starts:
```swift
AwesomeNetwork.start()
```

#### Using Semaphore

Let's say we are using a JWT token to all our API calls, but this token has to be refreshed every once in a while. Upon refreshing the token, we may experience invalid token in our requests that were fired before. To solve this issue, we can use a semaphore that can queue the requests and run them once given the green lights.

This framework supports this functionality, and to use it, start the framework with the following:
```swift
AwesomeNetwork.start(useDispatchQueue: true)
```

Then, once you are ready to start running the queued requests, run the following line:
```swift
AwesomeNetwork.releaseDispatchQueue()
```

It has to be done only once per execution.

#### Performing Requests

**Custom Request:**
```swift
/// Returns data either from cache or from URL
///
/// - Parameters:
///   - request: All params to fetch the data
///   - completion: (data, errorData)

AANetworking.requestData(_ request: AwesomeRequestParameters?,
                         completion:@escaping AAResponse)
```

**Generic Request: (Codable)**

```swift
/// Returns data either from cache or from URL
///
/// - Parameters:
///   - request: All params to fetch the data
///   - completion: (parsed codable object, errorData)

requestGeneric(with: AwesomeRequestParameters?,
               completion:@escaping (someObject: SomeCodableClass?, AwesomeError?)
```
```swift
/// Returns data either from cache or from URL
///
/// - Parameters:
///   - request: All params to fetch the data
///   - completion: (parsed codable object array, errorData)

requestGenericArray(with: AwesomeRequestParameters?,
                    completion:@escaping (someArray: [SomeCodableClass], AwesomeError?)
```

#### Downloading

```swift
AwesomeDownload.download(from: URL(string: "urlToDownloadFrom")!, toFolder: "folderName", force: true, completion: { (success) in
// download is completed
}, progressUpdated: {(progress) in
// progress updated (from 0 to 1)
})
```

**Downloading list of files:**

```swift
AwesomeDownloadManager.download(from urls: [URL])
```

Listen to download events as following:

```swift
/*
Possible Events:
downloading
downloaded
deleted
downloadCanceled
deleteCanceled
*/

// Listen to a download event
AwesomeDownloadManager.observe(to: event, 
inQueue: .main, 
whenUrl: url, 
using: { (notification) in
// notification.object is of type `AwesomeDownloadObject`
})

```

### Objective-C

Accessing public files and functions:
```obj-c
#import "AwesomeNetwork-Swift.h"
```

## Updating the code

As we are installing the Library with CocoaPods, we have to follow a few steps to make sure it will update in our project(s).

### Editing the Library

**Important:** Before beginning, make sure you are working on the **MASTER** branch.

Make sure you open the project in the following path:

```ruby
AwesomeRepository/Example/AwesomeRepository.xcworkspace
```

XCode will open with 2 projects:
- **AwesomeRepository** (your project configuration and usage example)
- **Pods** (your pod file classes)

All of the files that will be imported to our projects with cocoapods are in the following path

```ruby
Pods/Development Pods/AwesomeRepository/AwesomeRepository/Classes
```

Pick yours, edit it and be happy. Oh well, before being too happy, move to **Creating a new version for the Pod file** session to create a new version of the code.

### Testing the Library

Sometimes, you need to test your code before deploying a new version.
For any test, you can use the **Example for AwesomeRepository**.
All of the files created here will not be imported to our projects, so don't worry, be free to test it as if it was one of our projects.

### Creating a new version for the Pod file

Ok, so for starters, you have to work on the changes you wanted to make, right? Otherwise there is no point in creating a new version! ;)
*(Only proceed once you are ready to deploy)*

1. Navigate to file:

```ruby
AwesomeLocalization/Podspec Metadata/AwesomeRepository.podspec
```

2. Change the **s.version** by summing 1 to the end:

```ruby
//if version 0.1.3, the new version should be 0.1.4
//if version 0.1.9, the new version should be 0.2.0
```

3. Edit the **README.md** file with the new version:

```ruby
//update tag to match the current version
pod 'AwesomeRepository', git: 'https://github.com/iOSWizards/AwesomeRepository.git', tag: '0.1.0'
```

4. Commit your changes to **MASTER**
5. Create a new branch with the new version name. Push the new branch.
6. In your project, update the Podfile to match the new AwesomeLocalization version.
7. Run **pod install** and be happy :)

## License

AwesomeNetwork is available under the MIT license. See the LICENSE file for more info.
