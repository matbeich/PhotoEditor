//
// Copyright © 2018 Dimasno1. All rights reserved. Product:PhotoEditor
//

import UIKit

public extension UIViewController {
    func addChild(_ controller: UIViewController, to container: UIView) {
        controller.view.frame = container.bounds
        controller.willMove(toParent: self)
        view.addSubview(controller.view)
        addChild(controller)
        controller.didMove(toParent: self)
    }
}
