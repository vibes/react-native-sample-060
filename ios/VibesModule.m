//
//  VibesModule.m
//  reactNativeSample060
//
//  Created by Moin' Victor on 4/29/21.
//  Copyright © 2021 Facebook. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <React/RCTBridgeModule.h>
#import "reactNativeSample060-Swift.h"
@import VibesPush;

/**
 * This will expose `VibesModule` module to React JS
 */
@interface VibesModule : NSObject <RCTBridgeModule, VibesAPIDelegate>
@end

@implementation VibesModule
RCT_EXPORT_MODULE(); // or RCT_EXPLORT_MODULE(YourModuleName) -- custom name

RCTPromiseResolveBlock associatePersonResolver;
RCTPromiseRejectBlock associatePersonRejecter;

RCTPromiseResolveBlock registerPushResolver;
RCTPromiseRejectBlock registerPushRejecter;

RCTPromiseResolveBlock unregisterPushResolver;
RCTPromiseRejectBlock unregisterPushRejecter;

RCT_REMAP_METHOD(associatePerson, associatePerson: (NSString*) personId withResolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)
{
  Vibes const *vibes = [[VibesClient standard] vibes];
  [vibes setDelegate:self];
  associatePersonResolver = resolve;
  associatePersonRejecter = reject;
  [vibes associatePersonWithExternalPersonId:personId];
}

RCT_REMAP_METHOD(registerPush, registerPushWithResolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)
{
  Vibes const *vibes = [[VibesClient standard] vibes];
  [vibes setDelegate:self];
  registerPushResolver = resolve;
  registerPushRejecter = reject;
  [vibes registerPush];
}

RCT_REMAP_METHOD(unregisterPush, unregisterPushWithResolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)
{
  Vibes const *vibes = [[VibesClient standard] vibes];
  [vibes setDelegate:self];
  unregisterPushResolver = resolve;
  unregisterPushRejecter = reject;
  [vibes unregisterPush];
}

- (void)didAssociatePersonWithError:(NSError *)error
{
  if (error == NULL) {
    NSLog(@"---------->>>>>>>>>>>Associate Person Success ✅:");
    associatePersonResolver(@"Success");
  } else {
    NSLog(@"---------->>>>>>>>>>>Associate Person Error: %@", error);
    associatePersonRejecter(@"ASSOCIATE_PERSON_ERROR", error.localizedDescription, error);
  }
}

-(void)didRegisterPushWithError:(NSError *)error
{
  if (error == NULL) {
    NSLog(@"---------->>>>>>>>>>>Register Push Success ✅:");
    registerPushResolver(@"Success");
  } else {
    NSLog(@"---------->>>>>>>>>>>Register Push Error: %@", error);
    registerPushRejecter(@"REGISTER_PUSH_ERROR", error.localizedDescription, error);
  }
}

-(void)didUnregisterPushWithError:(NSError *)error
{
  if (error == NULL) {
    NSLog(@"---------->>>>>>>>>>>Unregister Push Success ✅:");
    unregisterPushResolver(@"Success");
  } else {
    NSLog(@"---------->>>>>>>>>>>Unregister Push Error: %@", error);
    unregisterPushRejecter(@"UNREGISTER_PUSH_ERROR", error.localizedDescription, error);
  }
}
@end
