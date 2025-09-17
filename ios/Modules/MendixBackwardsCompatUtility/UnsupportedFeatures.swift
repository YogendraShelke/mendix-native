//
//  UnsupportedFeatures.swift
//  MendixNative
//
//  Copyright (c) Mendix, Inc. All rights reserved.
//

import Foundation

@objc class UnsupportedFeatures: NSObject {
    @objc var reloadInClient: Bool
    @objc var hideSplashScreenInClient: Bool
    
    @objc init(reloadInClient: Bool) {
        self.reloadInClient = reloadInClient
        self.hideSplashScreenInClient = false
        super.init()
    }
    
    @objc init(reloadInClient: Bool, hideSplashScreenInClient: Bool) {
        self.reloadInClient = reloadInClient
        self.hideSplashScreenInClient = hideSplashScreenInClient
        super.init()
    }
}
