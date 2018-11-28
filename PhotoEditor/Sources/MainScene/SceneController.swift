//
// Copyright © 2018 Dimasno1. All rights reserved. Product: PhotoEditor
//

import SnapKit
import UIKit

class SceneController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .darkGray
        view.addSubview(toolBar)
        view.addSubview(photoViewControllerContainer)
        view.addSubview(toolControlsContainer)
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

        toolControlsContainer.snp.makeConstraints { make in
            make.bottom.equalTo(toolBar.snp.top)
            make.left.right.equalToSuperview()
            make.height.equalToSuperview().multipliedBy(0.15)
        }
    }

    private func changeAppearenceOfTools(for mode: EditMode) {
        switch mode {
        case .crop:
            toolControlsContainer.isHidden = true
        case .filter:
            toolControlsContainer.isHidden = false
            add(fullscreenChild: filtersCollectionViewController, in: toolControlsContainer)
        case .normal:
            toolControlsContainer.isHidden = true
            filtersCollectionViewController.removeFromParent()
        }
    }

    private func setup() {
        add(fullscreenChild: photoViewController, in: photoViewControllerContainer)

        Current.stateStore.bindSubscriber(with: id) { [weak self] state in
            self?.photoViewController.mode = state.value.editMode
            self?.changeAppearenceOfTools(for: state.value.editMode)
        }
    }

    private lazy var filtersCollectionViewController: FiltersCollectionViewController = {
        let filters = [
            "CIToneCurve", "CIPointillize", "CISpotColor",
            "CIPhotoEffectNoir", "CIBumpDistortion", "CITorusLensDistortion", "CIConvolution9Horizontal"
        ]

        return FiltersCollectionViewController(filterNames: filters)
    }()

    private lazy var toolBar: Toolbar = {
        let barItems = [
            BarButtonItem(title: "Crop", image: nil),
            BarButtonItem(title: "Filter", image: nil)
        ]
        let toolbar = Toolbar(frame: .zero, barItems: barItems)
        toolbar.delegate = self

        return toolbar
    }()

    private let photoViewController = PhotoViewController()
    private let toolControlsContainer = UIView()
    private let photoViewControllerContainer = UIView()
}

extension SceneController: ToolbarDelegate {
    func toolbar(_ toolbar: Toolbar, itemTapped: BarButtonItem) {
        if itemTapped.tag == 1 {
            Current.stateStore.state.value.editMode = .filter
            Current.photoEditService.resize(photoViewController.photo!, to: CGSize(width: 50, height: 50)) { [weak self] in
                self?.filtersCollectionViewController.image = $0
            }
        } else {
            Current.stateStore.state.value.editMode = .crop
        }
    }
}
