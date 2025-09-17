//
//  NativeCookieModule.swift
//  MendixNative
//
//  Created by Yogendra Shelke on 20/03/25.
//  Copyright © 2025 Mendix. All rights reserved.
//

import Foundation

@objc public class NativeCookieModule: NSObject {
    
  @objc public func clearAll() {
      ReactNative.instance.clearCookies()
    }
}
