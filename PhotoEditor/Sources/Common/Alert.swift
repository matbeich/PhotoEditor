//
// Copyright © 2018 Dimasno1. All rights reserved. Product:PhotoEditor
//

import UIKit

final class Alert {
    static func popUpMessage(_ message: String, duration: TimeInterval, in viewController: UIViewController) {
        let alertController = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        let completion = { alertController.dismiss(animated: true, completion: nil) }

        viewController.present(alertController, animated: true) { DispatchQueue.main.asyncAfter(deadline: .now() + duration, execute: completion) }
    }
}
