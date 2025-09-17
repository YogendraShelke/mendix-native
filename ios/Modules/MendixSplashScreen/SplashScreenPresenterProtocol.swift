//
//  SplashScreenPresenterProtocol.swift
//  MendixNative
//
//  Created by Yogendra Shelke on 05/09/25.
//  Copyright (c) Mendix, Inc. All rights reserved.
//

import UIKit

@objc protocol SplashScreenPresenterProtocol: AnyObject {
    func show(_ rootView: UIView?)
    func hide()
}
