//
//  ReactNative.swift
//  MendixNative
//
//  Created by Yogendra Shelke on 05/09/25.
//

import Foundation
import UIKit
import React
import Security

@objc protocol ReactNativeDelegate: AnyObject {
  func onAppClosed()
}

@objc class ReactNative: NSObject, RCTBridgeDelegate, RCTReloadListener {
  // MARK: - Properties
  private var bridge: RCTBridge?
  private var rootWindow: UIWindow?
  private var appWindow: UIWindow?
  private var mendixApp: MendixApp?
  private var bundleUrl: URL?
  private var launchOptions: [AnyHashable: Any]?
  private var mendixOTAEnabled: Bool = false
  
  @objc weak var delegate: ReactNativeDelegate?
  
  // Static properties
  private static var sharedInstance: ReactNative?
  private var rootViewController: UIViewController?
  private var tapGestureRecognizer: UITapGestureRecognizer?
  private var longPressGestureRecognizer: UILongPressGestureRecognizer?
  
  // MARK: - Singleton
  @objc static var instance: ReactNative {
    if sharedInstance == nil {
      sharedInstance = ReactNative()
    }
    return sharedInstance!
  }
  
  // MARK: - Initialization
  override init() {
    super.init()
    
    // Get the key window in a way that's compatible with different iOS versions
    if #available(iOS 13.0, *) {
      rootWindow = UIApplication.shared.connectedScenes
        .compactMap { $0 as? UIWindowScene }
        .first?.windows
        .first(where: { $0.isKeyWindow })
    } else {
      rootWindow = UIApplication.shared.keyWindow
    }
    
    rootViewController = rootWindow?.rootViewController
  }
  
  // MARK: - Public Static Methods
  @objc static func warningsFilterToString(_ warningsFilter: WarningsFilter) -> String {
    return warningsFilter.stringValue
  }
  
  @objc static func toAppScopeKey(_ key: String) -> String {
    guard let appName = MxConfiguration.appName, !appName.isEmpty else {
      return key
    }
    return "\(appName)_\(key)"
  }
  
  @objc static func clearKeychain() {
    let keys = [
      ReactNative.toAppScopeKey("token"),
      ReactNative.toAppScopeKey("session")
    ]
    
    for key in keys {
      deleteKeychainItem(withKey: key)
    }
  }
  
  private static func deleteKeychainItem(withKey key: String) {
    let query: [String: Any] = [
      kSecClass as String: kSecClassGenericPassword,
      kSecAttrAccount as String: key,
      kSecReturnData as String: kCFBooleanTrue!
    ]
    SecItemDelete(query as CFDictionary)
  }
  
  // MARK: - Setup Methods
  @objc func setup(_ mendixApp: MendixApp, launchOptions: [AnyHashable: Any]?) {
    self.mendixApp = mendixApp
    self.bundleUrl = mendixApp.bundleUrl
    self.launchOptions = launchOptions
    
    if let host = bundleUrl?.host, let port = bundleUrl?.port {
      let jsLocation = "\(host):\(port)"
      RCTBundleURLProvider.sharedSettings().jsLocation = jsLocation
    }
  }
  
  @objc func setup(_ mendixApp: MendixApp, launchOptions: [AnyHashable: Any]?, mendixOTAEnabled: Bool) {
    self.mendixOTAEnabled = mendixOTAEnabled
    setup(mendixApp, launchOptions: launchOptions)
  }
  
  // MARK: - Lifecycle Methods
  @objc func start() {
    guard let mendixApp = self.mendixApp else {
      fatalError("MendixApp not passed before starting the app")
    }
    
    MxConfiguration.runtimeUrl = mendixApp.runtimeUrl
    MxConfiguration.appName = mendixApp.identifier
    MxConfiguration.isDeveloperApp = mendixApp.isDeveloperApp
    MxConfiguration.databaseName = mendixApp.identifier!
    
    if let identifier = mendixApp.identifier {
      MxConfiguration.filesDirectoryName = "files/\(identifier)"
    }
    
    MxConfiguration.warningsFilter = mendixApp.warningsFilter
    
    let timestamp = Int64(Date().timeIntervalSince1970 * 1000.0)
    let randomValue = arc4random_uniform(1000)
    MxConfiguration.appSessionId = "\(randomValue)\(timestamp)"
    
    if mendixApp.clearDataAtLaunch {
      clearData()
    }
    
    let appLoadingController: UIViewController
    if let reactLoading = mendixApp.reactLoading {
      appLoadingController = reactLoading.instantiateInitialViewController()!
    } else {
      appLoadingController = UIViewController()
    }
    
    bridge = RCTBridge(delegate: self, launchOptions: launchOptions)
    bridge?.devSettings.isShakeToShowDevMenuEnabled = false
    bridge?.devSettings.isDebuggingRemotely = isDebuggingRemotely()
    
    let reactRootView = RCTRootView(bridge: bridge!, moduleName: "App", initialProperties: nil)
    reactRootView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    
    if let rootWindow = self.rootWindow {
      reactRootView.frame = rootWindow.rootViewController?.view.frame ?? .zero
      rootWindow.rootViewController = appLoadingController
      rootWindow.rootViewController?.view.addSubview(reactRootView)
    }
    
    showSplashScreen()
    
    if mendixApp.isDeveloperApp || mendixApp.enableThreeFingerGestures {
      if let rootWindow = self.rootWindow {
        attachThreeFingerGestures(to: rootWindow)
      }
      
      DispatchQueue.main.async {
        RCTRegisterReloadCommandListener(self)
      }
    }
  }
  
  @objc func stop() {
    hideSplashScreen()
    launchOptions = nil
    
    rootWindow?.isHidden = false
    rootWindow?.makeKeyAndVisible()
    
#if DEBUG
    if AppPreferences.isElementInspectorEnabled() {
      toggleElementInspector()
    }
    AppPreferences.setElementInspector(false)
#endif
    
    bridge?.invalidate()
    
    if let rootWindow = self.rootWindow {
      removeThreeFingerGestures(from: rootWindow)
      rootWindow.rootViewController = rootViewController
    }
    
    delegate?.onAppClosed()
    delegate = nil
    bridge = nil
  }
  
  // MARK: - State Methods
  @objc func isActive() -> Bool {
    return bridge != nil
  }
  
  // MARK: - Bundle Methods
  @objc func getJSBundleFile() -> URL? {
    if hasNativeOtaBundle() {
      if let bundleUrl = OtaJSBundleFileProvider.getBundleUrl() {
        return bundleUrl
      }
    }
    
    return Bundle.main.url(forResource: "index.ios", withExtension: "bundle", subdirectory: "Bundle")
  }
  
  private func hasNativeOtaBundle() -> Bool {
    return FileManager.default.contents(atPath: OtaHelpers.getOtaManifestFilepath()) != nil
  }
  
  // MARK: - Splash Screen Methods
  @objc func showSplashScreen() {
    DispatchQueue.main.async { [weak self] in
      guard let self = self,
            let mendixApp = self.mendixApp,
            !MendixBackwardsCompatUtility.unsupportedFeatures()!.hideSplashScreenInClient,
            let splashScreenPresenter = mendixApp.splashScreenPresenter else {
        return
      }
      
      splashScreenPresenter.show(self.getRootView())
    }
  }
  
  @objc func hideSplashScreen() {
    DispatchQueue.main.async { [weak self] in
      guard let self = self,
            let splashScreenPresenter = self.mendixApp?.splashScreenPresenter else {
        return
      }
      
      splashScreenPresenter.hide()
    }
  }
  
  // MARK: - Reload Methods
  @objc func reload() {
    showSplashScreen()
    
    if let mendixApp = self.mendixApp {
      let otaBundleUrl = OtaJSBundleFileProvider.getBundleUrl()
      if !mendixApp.isDeveloperApp, let otaBundleUrl = otaBundleUrl {
        bridge?.setValue(otaBundleUrl, forKey: "bundleURL")
      }
      
      if mendixApp.isDeveloperApp {
        let runtimeInfoUrl = AppUrl.forRuntimeInfo(mendixApp.runtimeUrl.absoluteString)
        RuntimeInfoProvider.getRuntimeInfo(runtimeInfoUrl) { [weak self] response in
          if response.status == "SUCCESS" {
            MendixBackwardsCompatUtility.update(response.runtimeInfo!.version)
          }
          self?.reloadWithBridge()
        }
      } else {
        reloadWithBridge()
      }
    }
  }
  
  private func reloadWithBridge() {
    RCTTriggerReloadCommandListeners("Mendix - reload")
  }
  
  @objc func reloadWithState() {
    if let reloadHandler = bridge?.module(for: ReloadHandler.self) as? ReloadHandler {
      reloadHandler.reloadClientWithState()
    }
  }
  
  // MARK: - RCTReloadListener
  func didReceiveReloadCommand() {
    showSplashScreen()
  }
  
  // MARK: - Data Clearing Methods
  @objc func clearData() {
    let documentPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    let libraryPath = FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask)[0]
    
    let filesDirectoryName = MxConfiguration.filesDirectoryName
    let filesPath = documentPath.appendingPathComponent(filesDirectoryName)
    _ = NativeFsModule.remove(filesPath.path, error: nil)
    
    clearAsyncStorage()
    ReactNative.clearKeychain()
    clearCookies()
    
    let databaseName = MxConfiguration.databaseName
    let databasePath = libraryPath.appendingPathComponent("LocalDatabase/\(databaseName)")
    _ = NativeFsModule.remove(databasePath.path, error: nil)
  }
  
  @objc func clearAsyncStorage() {
    // Implementation for clearing async storage
    // RNCAsyncStorage.clearAllData() // Commented out as in original
  }
  
  @objc func clearCookies() {
    let storage = HTTPCookieStorage.shared
    guard let cookies = storage.cookies else { return }
    
    for cookie in cookies {
      storage.deleteCookie(cookie)
    }
  }
  
  // MARK: - Debugging Methods
  @objc func remoteDebugging(_ enable: Bool) {
    showSplashScreen()
    AppPreferences.remoteDebugging(enable)
    
    let appUrl = AppPreferences.getAppUrl()!
    let port = AppPreferences.getRemoteDebuggingPackagerPort()
    bundleUrl = AppUrl.forBundle(appUrl, port: port, isDebuggingRemotely: enable, isDevModeEnabled: true)
    bridge?.devSettings.isDebuggingRemotely = enable
  }
  
  @objc func setRemoteDebuggingPackagerPort(_ port: Int) {
    AppPreferences.setRemoteDebuggingPackagerPort(port)
    remoteDebugging(true)
  }
  
  @objc func isDebuggingRemotely() -> Bool {
    return AppPreferences.devModeEnabled() && AppPreferences.remoteDebuggingEnabled()
  }
  
  // MARK: - Menu and Inspector Methods
  @objc func showAppMenu() {
    if let presentedViewController = RCTPresentedViewController(),
       !(presentedViewController is DevAppMenuUIAlertController) {
      if let devMenu = bridge?.module(for: RCTDevMenu.self) as? RCTDevMenu {
        devMenu.show()
      }
    }
  }
  
  @objc func toggleElementInspector() {
    bridge?.devSettings.toggleElementInspector()
  }
  
  // MARK: - Gesture Recognition
  private func attachThreeFingerGestures(to window: UIWindow) {
    if tapGestureRecognizer == nil {
      tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(appReloadAction(_:)))
      tapGestureRecognizer?.numberOfTouchesRequired = 3
    }
    if let tapGesture = tapGestureRecognizer {
      window.addGestureRecognizer(tapGesture)
    }
    
    if longPressGestureRecognizer == nil {
      longPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(appMenuShowAction(_:)))
      longPressGestureRecognizer?.numberOfTouchesRequired = 3
    }
    if let longPressGesture = longPressGestureRecognizer {
      window.addGestureRecognizer(longPressGesture)
    }
  }
  
  private func removeThreeFingerGestures(from window: UIWindow) {
    if let tapGesture = tapGestureRecognizer {
      window.removeGestureRecognizer(tapGesture)
    }
    
    if let longPressGesture = longPressGestureRecognizer {
      window.removeGestureRecognizer(longPressGesture)
    }
    
    window.motionBegan(.motionShake, with: nil)
  }
  
  @objc private func appReloadAction(_ gestureRecognizer: UITapGestureRecognizer) {
    if gestureRecognizer.state == .ended && bridge != nil {
      reloadWithState()
    }
  }
  
  @objc private func appMenuShowAction(_ gestureRecognizer: UILongPressGestureRecognizer) {
    if gestureRecognizer.state == .began {
      showAppMenu()
    }
  }
  
  // MARK: - Getter Methods
  @objc func getBridge() -> RCTBridge? {
    return bridge
  }
  
  @objc func getRootView() -> UIView? {
    return rootWindow?.rootViewController?.view
  }
  
  // MARK: - RCTBridgeDelegate
  func sourceURL(for bridge: RCTBridge) -> URL? {
    return bundleUrl
  }
  
  // MARK: - Legacy Methods (for compatibility)
  @objc func useCodePush() -> Bool {
    // Implementation depends on your specific CodePush setup
    return false
  }
}
