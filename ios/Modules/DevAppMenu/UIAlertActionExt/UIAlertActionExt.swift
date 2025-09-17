//
//  UIAlertActionExt.swift
//  MendixNative
//
//  Created by Yogendra Shelke on 05/09/25.
//  Copyright (c) Mendix, Inc. All rights reserved.
//

import UIKit
import ObjectiveC

extension UIAlertAction {
    private static var associatedIdentifierKey: UInt8 = 0
    
    @objc func setAccessibilityIdentifier(_ accessibilityIdentifier: String) {
        objc_setAssociatedObject(self, &UIAlertAction.associatedIdentifierKey, accessibilityIdentifier, .OBJC_ASSOCIATION_RETAIN)
    }
    
    @objc func getAccessibilityIdentifier() -> String? {
        return objc_getAssociatedObject(self, &UIAlertAction.associatedIdentifierKey) as? String
    }
}
