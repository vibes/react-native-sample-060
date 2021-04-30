//
//  VibesModule.swift
//  reactNativeSample060
//
//  Created by Moin' Victor on 4/29/21.
//  Copyright © 2021 Facebook. All rights reserved.
//

import Foundation
import VibesPush

/// Vibes Native Module
@objc(VibesModule)
class VibesModule: NSObject, VibesAPIDelegate {
    var associatePersonCallback: RCTResponseSenderBlock?

    static func requiresMainQueueSetup() -> Bool {
        return true
    }

    func setVibesDelegate() {
        VibesClient.standard.vibes.set(delegate: self)
    }

    /// This function will associate Person to expernal person ID.
    ///
    /// - Parameter externalPersonId: The external Person Id
    /// - Parameter callback: The callback to call when handled, with the `nil`|`Error`.
    @objc func associatePerson(_ externalPersonId: String, _ callback: @escaping RCTResponseSenderBlock) {
        setVibesDelegate()
        associatePersonCallback = callback
        debugPrint("associatePerson: \(externalPersonId) ...")
        VibesClient.standard.vibes.associatePerson(externalPersonId: externalPersonId)
    }

    func didAssociatePerson(error: Error?) {
        if let error = error {
            debugPrint("didAssociatePerson Failed: ", error.localizedDescription)
            associatePersonCallback?(["ASSOCIATE_PERSON_FAILED", error.localizedDescription])
        } else {
            debugPrint("didAssociatePerson Success")
            associatePersonCallback?([])
        }
    }
}
