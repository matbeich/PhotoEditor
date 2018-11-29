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

        toolControlsContainer.snp.makeConstraints { make in
            self.toolControlsConstainerTop = make.top.equalTo(toolBar.snp.top).constraint
            make.left.right.equalToSuperview()
            make.height.equalToSuperview().multipliedBy(0.15)
        }

        photoViewControllerContainer.snp.remakeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.bottom.equalTo(toolControlsContainer.snp.top)
        }
    }

    var toolControlsConstainerTop: Constraint?

    private func changeAppearenceOfTools(for mode: EditMode) {
        switch mode {
        case .crop:
            toolControlsConstainerTop?.update(offset: 0)

        case .filter:
            toolControlsConstainerTop?.update(offset: -toolControlsContainer.bounds.height)

        case .normal:
            filtersCollectionViewController.removeFromParent()
        }
    }

    private func setup() {
        add(fullscreenChild: photoViewController, in: photoViewControllerContainer)
        add(fullscreenChild: filtersCollectionViewController, in: toolControlsContainer)

        Current.stateStore.bindSubscriber(with: id) { [weak self] state in
            self?.changeAppearenceOfTools(for: state.value.editMode)
            self?.photoViewController.mode = state.value.editMode
        }

        photoViewController.originalPhoto = UIImage(named: "test.jpg")!
    }

    private lazy var filtersCollectionViewController: FiltersCollectionViewController = {
        let filters = Array(AppFilters.allCases).compactMap { CIFilter(name: $0.rawValue) }
        let controller = FiltersCollectionViewController(filters: filters)

        controller.delegate = self
        controller.view.backgroundColor = .lightGray

        return controller
    }()

    private lazy var toolBar: Toolbar = {
        let barItems = [
            BarButtonItem(title: "Crop", image: nil),
            BarButtonItem(title: "Filter", image: nil)
        ]
        let toolbar = Toolbar(frame: .zero, barItems: barItems)
        toolbar.delegate = self
        toolbar.backgroundColor = .white

        return toolbar
    }()

    private let photoViewController = PhotoViewController()
    private let toolControlsContainer = UIView()
    private let photoViewControllerContainer = UIView()
}

extension SceneController: ToolbarDelegate {
    func toolbar(_ toolbar: Toolbar, itemTapped: BarButtonItem) {
        if itemTapped.tag == 1 {
            guard let photo = photoViewController.cropedOriginal else {
                return
            }

            Current.stateStore.state.value.editMode = .filter
            Current.photoEditService.resize(photo, to: CGSize(width: 150, height: 150)) { [weak self] in
                self?.filtersCollectionViewController.image = $0
            }
        } else {
            Current.stateStore.state.value.editMode = .crop
        }
    }
}

extension SceneController: FiltersCollectionViewControllerDelegate {
    func filtersCollectionViewController(_ controller: FiltersCollectionViewController, didSelectFilter filter: EditFilter) {
        Current.photoEditService.asyncApplyFilter(filter, to: photoViewController.originalPhoto!) { [weak self] image in
            guard let image = image else {
                return
            }

            self?.photoViewController.setPhoto(image)
        }
    }
}
