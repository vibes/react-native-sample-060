# Description
 This repository shows how the Vibes Push SDK can be integrated into a React Native application natively.

 This repo supports React Native version `0.61.1`.

 ## General Requirements 
 1. You will need to obtain an application ID for your app from Vibes Customer Service. This will be referred to as `yourAppId` throughout this document.
 2. Everything you see in this repository is based on recommended behaviour in the Vibes Push Notification SDK documentation available [here](https://developer.vibes.com/display/APIs/Vibes+Push+Notifications+SDK).
 3. You will need to specify a url addressing our servers for different markets based on your target audience. This url is refferred to as `yourApiUrl` throughout this document. For the US market, the url is `https://public-api.vibescm.com/mobile_apps`. For  the non-US market, the url is `https://public-api.vibescmeurope.com/mobile_apps`. 

 ### Requirements for iOS
 1. You will need to replace the **yourAppId** AND **yourApiUrl** in the `ios/reactNativeSample060/Info.plist` with a previously obtained application ID and one of the server urls above.
 2. You will notice that the `ios/Podfile` file contains the reference to the Vibes SDK library for iOS. You may change the library version in this file.
 3. The rest of the code initializes and configures the environment to receive and display push notifications in an iOS environment. You are invited to copy and reuse as appropriate.

 ### Requirements for Android
 1. You will need to replace the **yourAppId** AND **yourApiUrl** in the `android/app/build.gradle` with a previously obtained application ID and one of the server urls above. These are passed into the AndroidManifest.xml file to configure the SDK.
 2. You will notice that the `android/app/build.gradle` file contains the reference to the Vibes SDK library for Android (**com.vibes.vibes:vibes:3.1.0**). Also take not of the versions of other dependencies such as firebase-messaging and google-play-services. Those are important, and should reflect in your react-native app.
 3. You will need to provide your own **google-services.json** file, matching one generated for the specific *applicationId* in the Firebase console.
 4. The rest of the code initializes and configures the environment to receive and display push notifications in an Android environment. You are invited to copy and reuse as appropriate.

## Native Bridge 
This sample code contains certain functions that are exposed via the React NativeModules functionality.

### Event for Push Receipt
When a push message is received, a `pushReceived` event is emitted. One can subscribe to the event followong this path.

```
import {NativeEventEmitter, NativeModules, DeviceEventEmitter} from 'react-native';
const onPushReceived = (event) => {
  alert('Push received. Payload -> ' + event.payload);
};

const eventEmitter = Platform.OS === 'ios' ? new NativeEventEmitter(NativeModules.PushEventEmitter) : DeviceEventEmitter;
eventEmitter.addListener('pushReceived', onPushReceived);
```

### Event for Push Opened
When a push message is opened by the user, a `pushOpened` event is emitted. One can subscribe to the event followong this path.

```
import {NativeEventEmitter, NativeModules, DeviceEventEmitter} from 'react-native';

const onPushOpened = async (event) => {
  if (Platform.OS === 'android') {
    await Vibes.invokeApp();
  }
  alert('Push opened. Payload -> ' + event.payload);
};

const eventEmitter = Platform.OS === 'ios' ? new NativeEventEmitter(NativeModules.PushEventEmitter) : DeviceEventEmitter;
eventEmitter.addListener('pushOpened', onPushOpened);
```

### Associating a User With a Device for Targeting
To link a device to a user, perhaps by their username/email or any other unique identifier, you can use the `associatePerson` bridge function.

```js
import Vibes from './Vibes';
...

const onPress = () => {
    try {
      const result = await Vibes.associatePerson('me@vibes.com');
      console.log(result)
    } catch (error) {
      console.error(error);
    }
  };
```

### Registering Push
To register push on the device. 
> This function assumes all necessary native setup is done with Firebase on Android and APNs on iOS. On iOS, you should have already asked for push notifications permissions somewhere in your AppDelegate.


```js
import Vibes from './Vibes';
...

const onPress = () => {
    try {
      console.log(Vibes)
      const result = await Vibes.registerPush();
      console.log(result)
    } catch (error) {
      console.error(error);
    }
  };
```

### Un-Registering Push
To unregister push on the device.


```js
import Vibes from './Vibes';
...

const onPress = () => {
    try {
      const result = await Vibes.unregisterPush();
      console.log(result)
    } catch (error) {
      console.error(error);
    }
  };
```

 ## Advanced Topics
 ### Rich Push
 #### Adding Rich Push for iOS
 To Add Rich Push to iOS, you need to add a Service Extenstion to the project. The service extension sits between the APNS server and the final content of the push and gets a limited execution time to perform some logic on the incoming push payload. This allows you to intercept the push content coming in from the APNS, modify it and then deliver the modified payload to the user.
 
 Steps to add:
 1. Go to the iOS project under `<your_rn_project>/ios` and open the `.xcworkspace` on XCode.
 2. On XCode create a new target by clicking `File ▸ New ▸ Target…`.
 3. Filter for the `Notification Service` Extension and click Next:
 ![Notification Service Dialog](/ios/dialog.png)
 4. Give it a name say `RichPush`, select Team, Bundle ID and language to use (you mostly want to stick with Swift here) and should be set to `Embeded in Application`(this is your main application project).Then click Finish.
 5. If you wish to expose some of the helper classes to the new services extension you created, select the file you wish to expose, go to `File Inspector` and add a check to your service extension target.
 ![File Inspector Dialog](/ios/file_inspect.png)
 6. Next go to your Apple Developer Page and create a `Siging Certificate and Provisioning Profile` for the `Bundle ID` you selected above. Make sure these are selected under `Signing & Capabilities` tab on your XCode project setting. You may also just use `Automatic Signing` if this suits your needs.
 ![Signing & Capabilities](/ios/sign.png)
 7. You new RichPush target will have a `NotificationService.swift` file created wich should allow you to intercept and modify the notification. 
 ```swift
 import UserNotifications
import MobileCoreServices

@available(iOS 10.0, *)
class NotificationService: UNNotificationServiceExtension {
  let parse = RichPushNotificationParsing()
  
  override func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
      // you may add your notification Parser here e.g to intercept and maybe dowload a media as in our case
    parse.didReceive(request, withContentHandler: contentHandler)
  }
  
  override func serviceExtensionTimeWillExpire() {
    parse.serviceExtensionTimeWillExpire()
  }
}
 ```
8. This is how the notification Parser may loook like if you are looking to download image with url specified in `client_app_data` using the key `media_url` when posted from the Campaign Manager.

```swift
import UIKit
import UserNotifications

class RichPushNotificationParsing: NSObject {
    var contentHandler: ((UNNotificationContent) -> Void)?
    var bestAttemptContent: UNMutableNotificationContent?
    fileprivate let kClientDataKey = "client_app_data"
    fileprivate let kMediaUrlKey = "media_url"
    fileprivate let kRichContentIdentifier = "richContent"
    
    func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
        self.contentHandler = contentHandler
        bestAttemptContent = (request.content.mutableCopy() as? UNMutableNotificationContent)
        
        if let bestAttemptContent = bestAttemptContent {
            if let clientData = bestAttemptContent.userInfo[kClientDataKey] as? [String: Any] {
                
                guard let attachmentString = clientData[kMediaUrlKey] as? String else {
                    return
                }

                if let attachmentUrl = URL(string: attachmentString) {
                    let session = URLSession(configuration: URLSessionConfiguration.default)
                    let attachmentDownloadTask = session.downloadTask(with: attachmentUrl, completionHandler: { (location, response, error) in
                        if let location = location {
                            let tmpDirectory = NSTemporaryDirectory()
                            let tmpFile = "file://".appending(tmpDirectory).appending(attachmentUrl.lastPathComponent)
                            let tmpUrl = URL(string: tmpFile)!
                            do {
                                try FileManager.default.moveItem(at: location, to: tmpUrl)
                                if let attachment = try? UNNotificationAttachment(identifier: self.kRichContentIdentifier, url: tmpUrl) {
                                    self.bestAttemptContent?.attachments = [attachment]
                                }
                            } catch {
                                print("An exception was caught while downloading the rich content!")
                            }
                        }
                        // Serve the notification content
                        self.contentHandler!(self.bestAttemptContent!)
                    })
                    attachmentDownloadTask.resume()
                }
            }
        }
    }
    
    func serviceExtensionTimeWillExpire() {
        // Called just before the extension will be terminated by the system.
        // Use this as an opportunity to deliver your "best attempt" at modified content, otherwise the original push payload will be used.
        if let contentHandler = contentHandler, let bestAttemptContent =  bestAttemptContent {
            contentHandler(bestAttemptContent)
        }
    }
}
```
9. Compile and Build your project to a device capable of receiving Push notifications on the APNs certificate used for your application project.
10. You should end up with Rich Push notification, when you send a broadcast that has a media attachment from the Campaign Manager.

