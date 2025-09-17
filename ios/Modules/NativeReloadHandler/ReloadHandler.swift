
import Foundation
import React

@objc public class ReloadHandler: RCTEventEmitter {
  
  @objc public static let reloadWithStateEventName: String = "reloadWithState"
  
  @objc public static let supportedEvents: [String] = [reloadWithStateEventName]
  
  @objc public func reload() {
    DispatchQueue.main.async {
      ReactNative.instance.reload()
    }
  }
  
  @objc public func reloadClientWithState() {
    sendEvent(withName: ReloadHandler.reloadWithStateEventName, body: nil)
  }
  
  @objc public func exitApp() {
    exit(0);
  }
}
