//
//  RuntimeInfo.swift
//  MendixNative
//
//  Created by Yogendra Shelke on 05/09/25.
//  Copyright (c) Mendix, Inc. All rights reserved.
//

import Foundation

@objc class RuntimeInfo: NSObject {
    
    // MARK: - Properties
    @objc let cacheburst: String
    @objc let nativeBinaryVersion: Int
    @objc let packagerPort: Int
    @objc let version: String
    
    // MARK: - Initialization
    @objc init(version: String, cacheburst: String, nativeBinaryVersion: Int, packagerPort: Int) {
        self.version = version
        self.cacheburst = cacheburst
        self.nativeBinaryVersion = nativeBinaryVersion
        self.packagerPort = packagerPort
        super.init()
    }
}
