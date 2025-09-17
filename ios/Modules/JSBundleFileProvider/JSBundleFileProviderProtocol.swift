//
//  JSBundleFileProviderProtocol.swift
//  MendixNative
//
//  Copyright (c) Mendix, Inc. All rights reserved.
//

import Foundation

@objc protocol JSBundleFileProviderProtocol: NSObjectProtocol {
    @objc static func getBundleUrl() -> URL?
}
