//
// Copyright © 2018 Dimasno1. All rights reserved. Product: PhotoEditor
//

import PhotoEditorKit
import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = navigator.rootViewController
        window?.makeKeyAndVisible()

        return true
    }

    let navigator = AppNavigator()
}
