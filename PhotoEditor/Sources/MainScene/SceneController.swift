//
// Copyright © 2018 Dimasno1. All rights reserved. Product: PhotoEditor
//

import UIKit

class SceneController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white
    }

    private let toolBar = ToolBar()
    private let toolControlsContainer = UIView()
    private let photoViewController = PhotoViewController()
}
