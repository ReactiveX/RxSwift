//
//  AppDelegate.swift
//  Example
//
//  Created by Krunoslav Zaher on 2/21/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func applicationDidFinishLaunching(_ application: UIApplication) {
        if UIApplication.isInUITest {
            UIView.setAnimationsEnabled(false)
        }
    }
}

