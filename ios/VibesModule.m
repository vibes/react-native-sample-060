//
//  VibesModule.m
//  reactNativeSample060
//
//  Created by Moin' Victor on 4/29/21.
//  Copyright © 2021 Facebook. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <React/RCTBridgeModule.h>

/**
This will expose `VibesModule` module to React JS
*/
@interface RCT_EXTERN_MODULE (VibesModule, NSObject)

//RCT_EXTERN_METHOD(someFunc:(RCTResponseSenderBlock)callback)
RCT_EXTERN_METHOD(associatePerson:(NSString *)externalPersonId:(RCTResponseSenderBlock)callback)


@end
