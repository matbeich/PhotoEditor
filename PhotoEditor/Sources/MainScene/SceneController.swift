//
// Copyright © 2018 Dimasno1. All rights reserved. Product: PhotoEditor
//

import SnapKit
import UIKit

class SceneController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .darkGray
        view.addSubview(photoViewControllerContainer)
        view.addSubview(toolControlsContainer)
        view.addSubview(toolBar)
        setup()

        makeConstraints()
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }

    private func makeConstraints() {
        toolBar.snp.makeConstraints { make in
            make.bottom.left.right.equalToSuperview()
            make.height.equalTo(Config.toolBarHeight)
        }

        photoViewControllerContainer.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.bottom.equalTo(toolBar.snp.top)
        }
    }

    private func setup() {
        add(fullscreenChild: photoViewController, in: photoViewControllerContainer)
    }

    private let photoViewController = PhotoViewController()
    private let toolBar = ToolBar()
    private let toolControlsContainer = UIView()
    private let photoViewControllerContainer = UIView()
}
