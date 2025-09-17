//
//  RCTRedBoxHelper.swift
//  MendixNative
//
//  Created by Yogendra Shelke on 05/09/25.
//  Copyright © 2024 Mendix. All rights reserved.
//

import Foundation
import React

@objc class RedBoxHelper: NSObject {
    
    // MARK: - Properties
    @objc var redBox: RCTRedBox?
    
    // MARK: - Singleton
    private static var _sharedInstance: RedBoxHelper?
    private static let queue = DispatchQueue(label: "com.mendix.redboxhelper")
    
    @objc static func sharedInstance() -> RedBoxHelper {
        return queue.sync {
            if _sharedInstance == nil {
                _sharedInstance = RedBoxHelper()
                _sharedInstance?.redBox = RCTRedBox()
            }
            return _sharedInstance!
        }
    }
    
    // MARK: - Initialization
    private override init() {
        super.init()
    }
}
