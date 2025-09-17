//
//  AppMenuProtocol.swift
//  MendixNative
//
//  Created by Yogendra Shelke on 05/09/25.
//  Copyright (c) Mendix, Inc. All rights reserved.
//

import Foundation

@objc protocol AppMenuProtocol: AnyObject {
    func show(_ devMode: Bool)
}
