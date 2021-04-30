//
//  PushEventEmitter.swift
//  reactNativeSample060
//
//  Created by Moin' Victor on 4/28/21.
//  Copyright © 2021 Facebook. All rights reserved.
//

import Foundation

/// Event emitter for Push related stuff
@objc(PushEventEmitter)
open class PushEventEmitter: RCTEventEmitter {
    public static var emitter: RCTEventEmitter!

    @objc
    override public static func requiresMainQueueSetup() -> Bool {
        return true
    }

    override init() {
        super.init()
        PushEventEmitter.emitter = self
    }

    override open func supportedEvents() -> [String] {
        return ["pushReceived", "pushOpened"]
    }

    /// Emitts the `pushReceived` event 
    @objc
    class func sendPushReceivedEvent(_ payload: JSONDictionary) {
        // we want to be sure this runs in the next run loop, after bridge is set
        DispatchQueue.main.asyncAfter(deadline: .now()) {
            if let emitter = PushEventEmitter.emitter { // check that RNEventEmitter has init
                debugPrint("Emitting onPushReceived event")
                emitter.sendEvent(withName: "pushReceived", body: payload)
            }
        }
    }
  
  /// Emitts the `pushOpened` event
  @objc
  class func sendPushOpenedEvent(_ payload: JSONDictionary) {
      // we want to be sure this runs in the next run loop, after bridge is set
      DispatchQueue.main.asyncAfter(deadline: .now()) {
          if let emitter = PushEventEmitter.emitter { // check that RNEventEmitter has init
              debugPrint("Emitting onPushOpened event")
              emitter.sendEvent(withName: "pushOpened", body: payload)
          }
      }
  }
}
