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

    func add(safeAreaChild controller: UIViewController, in container: UIView) {
        add(childController: controller, in: container) { parent, child in
            child.view.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                child.view.topAnchor.constraint(equalTo: container.safeAreaLayoutGuide.topAnchor),
                child.view.bottomAnchor.constraint(equalTo: container.bottomAnchor),
                child.view.leftAnchor.constraint(equalTo: container.leftAnchor),
                child.view.rightAnchor.constraint(equalTo: container.rightAnchor)])
        }
    }
}
