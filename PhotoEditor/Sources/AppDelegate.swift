//
// Copyright © 2018 Dimasno1. All rights reserved. Product: PhotoEditor
//

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

    func applicationWillEnterForeground(_ application: UIApplication) {
        Current.stateStore.state.value.appState = .active
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        Current.stateStore.state.value.appState = .background
    }

    func applicationWillResignActive(_ application: UIApplication) {
        Current.stateStore.state.value.appState = .inactive
    }

    let navigator = AppNavigator()
}
