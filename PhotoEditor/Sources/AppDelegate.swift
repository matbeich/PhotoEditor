//
//  AppDelegate.swift
//  PhotoEditor
//
//  Created by Admin on 11/6/18.
//  Copyright © 2018 Admin. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = SceneController()
        window?.makeKeyAndVisible()

        return true
    }
}
