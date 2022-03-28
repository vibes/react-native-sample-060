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

+ (BOOL)requiresMainQueueSetup
{
  return true;
}

- (instancetype)init
{
  self = [super init];
  if (self) {
    [[NSNotificationCenter defaultCenter] addObserver:self
            selector:@selector(didRegisterPushResultNotification:)
            name: [VibesClient didRegisterPushNSNotifName]
            object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
            selector:@selector(didUnregisterPushResultNotification:)
            name:[VibesClient didUnRegisterPushNSNotifName]
            object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
            selector:@selector(didAssociatePersonResultNotification:)
            name: [VibesClient didAssociatePersonNSNotifName]
            object:nil];
  }
  return self;
}

- (void) dealloc
{
    // If you don't remove yourself as an observer, the Notification Center
    // will continue to try and send notification objects to the deallocated
    // object.
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

RCT_REMAP_METHOD(associatePerson, associatePerson: (NSString*) personId withResolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)
{
  associatePersonResolver = resolve;
  associatePersonRejecter = reject;
  Vibes const *vibes = [[VibesClient standard] vibes];
  [vibes associatePersonWithExternalPersonId:personId];
}

RCT_REMAP_METHOD(registerPush, registerPushWithResolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)
{
  registerPushResolver = resolve;
  registerPushRejecter = reject;
  Vibes const *vibes = [[VibesClient standard] vibes];
  [vibes registerPush];
}

RCT_REMAP_METHOD(unregisterPush, unregisterPushWithResolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)
{
  unregisterPushResolver = resolve;
  unregisterPushRejecter = reject;
  Vibes const *vibes = [[VibesClient standard] vibes];
  [vibes unregisterPush];
}

- (void)didAssociatePersonResultNotification:(NSNotification *) notification
{
  NSError* error = notification.object;
  if (error == NULL) {
    NSLog(@"didAssociatePersonResultNotification Success ✅:");
    if (associatePersonResolver != NULL) {
      associatePersonResolver(@"Success");
    }
  } else {
    NSLog(@"didAssociatePersonResultNotification Error: %@", error);
    if (associatePersonRejecter != NULL) {
      associatePersonRejecter(@"ASSOCIATE_PERSON_ERROR", error.localizedDescription, error);
    }
  }
  associatePersonResolver = NULL;
  associatePersonRejecter = NULL;
}

-(void)didRegisterPushResultNotification:(NSNotification *) notification
{
  NSError* error = notification.object;
  if (error == NULL) {
    NSLog(@"didRegisterPushResultNotification Success ✅:");
    if (registerPushResolver != NULL) {
      registerPushResolver(@"Success");
    }
  } else {
    NSLog(@"didRegisterPushResultNotification Error: %@", error);
    if (registerPushRejecter != NULL) {
      registerPushRejecter(@"REGISTER_PUSH_ERROR", error.localizedDescription, error);
    }
  }
  registerPushResolver = NULL;
  registerPushRejecter = NULL;
}

-(void)didUnregisterPushResultNotification:(NSNotification *) notification
{
  NSError* error = notification.object;
  if (error == NULL) {
    NSLog(@"didUnregisterPushResultNotification Success ✅:");
    if (unregisterPushResolver != NULL) {
      unregisterPushResolver(@"Success");
    }
  } else {
    NSLog(@"didUnregisterPushResultNotification Error: %@", error);
    if (unregisterPushRejecter != NULL) {
      unregisterPushRejecter(@"UNREGISTER_PUSH_ERROR", error.localizedDescription, error);
    }
  }
  unregisterPushResolver = NULL;
  unregisterPushRejecter = NULL;
}
@end
