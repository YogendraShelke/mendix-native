//
//  UIAlertControllerExt.swift
//  MendixNative
//
//  Created by Yogendra Shelke on 05/09/25.
//  Copyright (c) Mendix, Inc. All rights reserved.
//

import UIKit

extension UIAlertController {
    @objc func applyAccessibilityIdentifiers() {
        for action in actions {
            if let label = action.value(forKey: "__representer") as? UIView,
               let identifier = action.getAccessibilityIdentifier() {
                label.accessibilityIdentifier = identifier
            }
        }
    }
}
