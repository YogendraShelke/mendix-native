//
//  RuntimeInfoResponse.swift
//  MendixNative
//
//  Created by Yogendra Shelke on 05/09/25.
//  Copyright (c) Mendix, Inc. All rights reserved.
//

import Foundation

@objc class RuntimeInfoResponse: NSObject {
    
    // MARK: - Properties
    @objc let status: String
    @objc let runtimeInfo: RuntimeInfo?
    
    // MARK: - Initialization
    @objc init(status: String, runtimeInfo: RuntimeInfo?) {
        self.status = status
        self.runtimeInfo = runtimeInfo
        super.init()
    }
}
