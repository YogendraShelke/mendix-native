//
//  AppPreferences.swift
//  MendixNative
//
//  Created by Yogendra Shelke on 05/09/25.
//  Copyright (c) Mendix, Inc. All rights reserved.
//

import Foundation

@objc class AppPreferences: NSObject {
    
    // MARK: - Constants
    private static let appUrlKey = "ApplicationUrl"
    private static let devModeEnabledKey = "DevModeEnabled"
    private static let clearDataEnabledKey = "ClearData"
    private static let remoteDebuggingEnabledKey = "RemoteDebuggingEnabled"
    private static let remoteDebuggingPackagerPortKey = "RemoteDebuggingPackagerPort"
    private static let elementInspectorDebugKey = "showInspector"
    
    // MARK: - App URL Methods
    @objc static func getAppUrl() -> String? {
        return UserDefaults.standard.string(forKey: appUrlKey)
    }
    
    @objc static func setAppUrl(_ url: String) {
        UserDefaults.standard.set(url, forKey: appUrlKey)
    }
    
    // MARK: - Dev Mode Methods
    @objc static func devModeEnabled() -> Bool {
        return UserDefaults.standard.bool(forKey: devModeEnabledKey)
    }
    
    @objc static func devMode(_ enable: Bool) {
        UserDefaults.standard.set(enable, forKey: devModeEnabledKey)
    }
    
    // MARK: - Remote Debugging Methods
    @objc static func remoteDebuggingEnabled() -> Bool {
        return UserDefaults.standard.bool(forKey: remoteDebuggingEnabledKey)
    }
    
    @objc static func remoteDebugging(_ enable: Bool) {
        UserDefaults.standard.set(enable, forKey: remoteDebuggingEnabledKey)
    }
    
    @objc static func getRemoteDebuggingPackagerPort() -> Int {
        let port = UserDefaults.standard.integer(forKey: remoteDebuggingPackagerPortKey)
        return port != 0 ? port : AppUrl.defaultPackagerPort()
    }
    
    @objc static func setRemoteDebuggingPackagerPort(_ port: Int) {
        UserDefaults.standard.set(port, forKey: remoteDebuggingPackagerPortKey)
    }
    
    // MARK: - Element Inspector Methods
    @objc static func isElementInspectorEnabled() -> Bool {
        return UserDefaults.standard.bool(forKey: elementInspectorDebugKey)
    }
    
    @objc static func setElementInspector(_ enable: Bool) {
        UserDefaults.standard.set(enable, forKey: elementInspectorDebugKey)
    }
}
