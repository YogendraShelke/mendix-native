//
//  MendixSplashScreen.swift
//  MendixNative
//
//  Created by Yogendra Shelke on 05/09/25.
//  Copyright (c) Mendix, Inc. All rights reserved.
//

import Foundation

@objc public class MendixSplashScreen: NSObject {
  
  @objc public func show() {
    ReactNative.instance.showSplashScreen()
  }
  
  @objc public func hide() {
    ReactNative.instance.hideSplashScreen()
  }
}
