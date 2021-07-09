import VibesPush

@objcMembers
class VibesClient: NSObject {
  static let standard = VibesClient()
  static let didRegisterPushNSNotifName = "DidRegisterPush"
  static let didUnRegisterPushNSNotifName = "DidUnRegisterPush"
  static let didAssociatePersonNSNotifName = "DidAssociatePerson"
  
  public let vibes: Vibes
  
  private override init() {
    // ensure we have Vibes app url set in current build config's Info.plist
    guard let appUrl = Configuration.configValue(.vibesAppURL) else {
        fatalError("`\(ConfigKey.vibesAppURL.value())` must be set in plist file of current build configuration")
    }
    // ensure we have Vibes app id set in current build config's Info.plist
    guard let appId = Configuration.configValue(.vibesAppId) else {
        fatalError("`\(ConfigKey.vibesAppId.value())` must be set in plist file of current build configuration")
    }

    let config = VibesConfiguration(advertisingId: nil,
                                    apiUrl: appUrl,
                                    logger: nil,
                                    storageType: .USERDEFAULTS)
    
    Vibes.configure(appId: appId, configuration: config)
    self.vibes = Vibes.shared
  }
}
