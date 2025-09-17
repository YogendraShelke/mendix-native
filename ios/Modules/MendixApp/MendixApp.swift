//
//  MendixApp.swift
//  MendixNative
//
//  Created by Yogendra Shelke on 05/09/25.
//  Copyright (c) Mendix, Inc. All rights reserved.
//

import Foundation
import UIKit

@objc class MendixApp: NSObject {
    // MARK: - Properties
    @objc var bundleUrl: URL
    @objc var runtimeUrl: URL
    @objc var warningsFilter: WarningsFilter
    @objc var identifier: String?
    @objc var isDeveloperApp: Bool
    @objc var clearDataAtLaunch: Bool
    @objc var appMenu: AppMenuProtocol?
    @objc var splashScreenPresenter: SplashScreenPresenterProtocol?
    @objc var reactLoading: UIStoryboard?
    @objc var enableThreeFingerGestures: Bool
    
    // MARK: - Initialization Methods
    
    /// Base initializer - all other initializers delegate to this one
    @objc init(identifier: String?,
               bundleUrl: URL,
               runtimeUrl: URL,
               warningsFilter: WarningsFilter,
               isDeveloperApp: Bool,
               clearDataAtLaunch: Bool) {
        self.identifier = identifier
        self.bundleUrl = bundleUrl
        self.runtimeUrl = runtimeUrl
        self.warningsFilter = warningsFilter
        self.isDeveloperApp = isDeveloperApp
        self.clearDataAtLaunch = clearDataAtLaunch
        self.appMenu = DevAppMenu()
        self.enableThreeFingerGestures = false
        self.splashScreenPresenter = nil
        self.reactLoading = nil
        
        super.init()
    }
    
    /// Initializer with splash screen presenter
    @objc convenience init(identifier: String?,
                          bundleUrl: URL,
                          runtimeUrl: URL,
                          warningsFilter: WarningsFilter,
                          isDeveloperApp: Bool,
                          clearDataAtLaunch: Bool,
                          splashScreenPresenter: SplashScreenPresenterProtocol) {
        self.init(identifier: identifier,
                  bundleUrl: bundleUrl,
                  runtimeUrl: runtimeUrl,
                  warningsFilter: warningsFilter,
                  isDeveloperApp: isDeveloperApp,
                  clearDataAtLaunch: clearDataAtLaunch)
        self.splashScreenPresenter = splashScreenPresenter
    }
    
    /// Initializer with react loading storyboard
    @objc convenience init(identifier: String?,
                          bundleUrl: URL,
                          runtimeUrl: URL,
                          warningsFilter: WarningsFilter,
                          isDeveloperApp: Bool,
                          clearDataAtLaunch: Bool,
                          reactLoading: UIStoryboard) {
        self.init(identifier: identifier,
                  bundleUrl: bundleUrl,
                  runtimeUrl: runtimeUrl,
                  warningsFilter: warningsFilter,
                  isDeveloperApp: isDeveloperApp,
                  clearDataAtLaunch: clearDataAtLaunch)
        self.reactLoading = reactLoading
    }
    
    /// Initializer with splash screen presenter and three finger gestures
    @objc convenience init(identifier: String?,
                          bundleUrl: URL,
                          runtimeUrl: URL,
                          warningsFilter: WarningsFilter,
                          isDeveloperApp: Bool,
                          clearDataAtLaunch: Bool,
                          splashScreenPresenter: SplashScreenPresenterProtocol,
                          enableThreeFingerGestures: Bool) {
        self.init(identifier: identifier,
                  bundleUrl: bundleUrl,
                  runtimeUrl: runtimeUrl,
                  warningsFilter: warningsFilter,
                  isDeveloperApp: isDeveloperApp,
                  clearDataAtLaunch: clearDataAtLaunch,
                  reactLoading: splashScreenPresenter as! UIStoryboard)
        self.enableThreeFingerGestures = enableThreeFingerGestures
    }
    
    /// Initializer with react loading storyboard and three finger gestures
    @objc convenience init(identifier: String?,
                          bundleUrl: URL,
                          runtimeUrl: URL,
                          warningsFilter: WarningsFilter,
                          isDeveloperApp: Bool,
                          clearDataAtLaunch: Bool,
                          reactLoading: UIStoryboard,
                          enableThreeFingerGestures: Bool) {
        self.init(identifier: identifier,
                  bundleUrl: bundleUrl,
                  runtimeUrl: runtimeUrl,
                  warningsFilter: warningsFilter,
                  isDeveloperApp: isDeveloperApp,
                  clearDataAtLaunch: clearDataAtLaunch,
                  reactLoading: reactLoading)
        self.enableThreeFingerGestures = enableThreeFingerGestures
    }
}
