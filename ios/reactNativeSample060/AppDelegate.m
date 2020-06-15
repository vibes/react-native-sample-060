/**
 * Copyright (c) Facebook, Inc. and its affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import "AppDelegate.h"

#import <React/RCTBridge.h>
#import <React/RCTBundleURLProvider.h>
#import <React/RCTRootView.h>

#import <UserNotifications/UserNotifications.h>
#import <React/RCTPushNotificationManager.h>
#import <reactNativeSample060-Swift.h>

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions: (NSDictionary *)launchOptions
{
  NSURL *jsCodeLocation;
  
  jsCodeLocation = [[RCTBundleURLProvider sharedSettings] jsBundleURLForBundleRoot: @"index" fallbackResource:nil];
  
  RCTRootView *rootView = [[RCTRootView alloc] initWithBundleURL: jsCodeLocation
                                                      moduleName: @"reactNativeSample060"
                                               initialProperties: nil
                                                   launchOptions: launchOptions];
  rootView.backgroundColor = [[UIColor alloc] initWithRed: 1.0f green: 1.0f blue: 1.0f alpha: 1];
  
  [[UNUserNotificationCenter currentNotificationCenter] setDelegate: self];
  
  Vibes const *vibes = [[VibesClient standard] vibes];
  [vibes setDelegate:(id) self];
  [vibes registerDevice];

  self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
  UIViewController *rootViewController = [UIViewController new];
  rootViewController.view = rootView;
  self.window.rootViewController = rootViewController;
  [self.window makeKeyAndVisible];
  return YES;
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
  // setting it to -1 clears badge but does not remove from list
  [application setApplicationIconBadgeNumber: -1];
}

-(void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
  NSLog(@"Receive remote push notif");
  
  Vibes const *vibes = [[VibesClient standard] vibes];
  [vibes receivedPushWith:userInfo at:[NSDate new]];
  
}

// Required to register for notifications
- (void)application:(UIApplication *)application didRegisterUserNotificationSettings: (UIUserNotificationSettings *)notificationSettings
{
  [RCTPushNotificationManager didRegisterUserNotificationSettings: notificationSettings];
}
// Required for the register event.
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken: (NSData *)deviceToken
{
  NSString * tokenString = [self stringWithDeviceToken: deviceToken];
  NSLog(@"------------------>>>>Push Token String: %@", tokenString);
  Vibes const *vibes = [[VibesClient standard] vibes];
  [vibes setPushTokenFromData: deviceToken];
  [RCTPushNotificationManager didRegisterForRemoteNotificationsWithDeviceToken: deviceToken];
}

// Required for the notification event. You must call the completion handler after handling the remote notification.
- (void)userNotificationCenter:(UNUserNotificationCenter* )center willPresentNotification:(UNNotification* )notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions options))completionHandler {
  
  completionHandler(UNNotificationPresentationOptionAlert);
  
}

// Required for the registrationError event.
- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
  Vibes const *vibes = [[VibesClient standard] vibes];
  [vibes unregisterPush];
  [RCTPushNotificationManager didFailToRegisterForRemoteNotificationsWithError:error];
}

- (NSString *)stringWithDeviceToken:(NSData*) deviceToken {
  const char *data = [deviceToken bytes];
  NSMutableString *token = [NSMutableString string];
  
  for (NSUInteger i = 0; i < [deviceToken length]; i++) {
    [token appendFormat:@"%02.2hhX", data[i]];
  }
  
  return [token copy];
}

- (void)requestAuthorizationForNotifications {
#if __IPHONE_OS_VERSION_MIN_REQUIRED < __IPHONE_10_0

  dispatch_async(dispatch_get_main_queue(), ^{
    [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge) categories:nil]];
    [[UIApplication sharedApplication] registerForRemoteNotifications];
  });
#else
  UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
  center.delegate = self;
  [center requestAuthorizationWithOptions:(UNAuthorizationOptionSound | UNAuthorizationOptionAlert | UNAuthorizationOptionBadge) completionHandler:^(BOOL granted, NSError * _Nullable error) {
    if (error) {
      NSLog(@"ERROR registering for push: %@ - %@", error.localizedFailureReason, error.localizedDescription );
    } else if (granted) {
       NSLog(@"authorization granted for push");
    } else {
      NSLog(@"authorization denied for push");
    }
  }];
#endif
}

- (void)didRegisterDeviceWithDeviceId:(NSString *)deviceId error:(NSError *)error {
  if (error == NULL) {
    NSLog(@"---------->>>>>>>>>>>Register Device with deviceID success ✅: %@", deviceId);

    [[NSUserDefaults standardUserDefaults] setObject: deviceId forKey:@"VibesDeviceID"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self requestAuthorizationForNotifications];
    
  } else {
    NSLog(@"---------->>>>>>>>>>>didRegisterDevice Error Device with deviceID--->>>: %@", error);
  }
}

- (void)didRegisterPushWithError:(NSError*) error {
  if (error == NULL) {
    NSLog(@"---------->>>>>>>>>>>Register Push success ✅:");
  } else {
    NSLog(@"---------->>>>>>>>>>>didRegisterPush Error register device: %@", error);
  }
}

- (void) didRegisterDevice:(NSString*) deviceId withError: (NSError*) error
{
  if (error == NULL) {
    NSLog(@"---------->>>>>>>>>>>Register Device success ✅:");
  } else {
    NSLog(@"didRegisterDevice Error register device: %@", error);
  }
}

- (void)didUnregisterDeviceWithError:(NSError*) error {
  if (error == NULL) {
    NSLog(@"---------->>>>>>>>>>>UnRegister Push success ✅:");
  } else {
    NSLog(@"---------->>>>>>>>>>>didRegisterPush Error register device: %@", error);
  }
}

@end
