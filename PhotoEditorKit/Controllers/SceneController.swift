//
// Copyright © 2018 Dimasno1. All rights reserved. Product: PhotoEditor
//

import Photos
import PhotosUI
import SnapKit
import UIKit


open class SceneController: UIViewController {
    public init(context: AppContext) {
        self.context = context
        self.photoViewController = PhotoViewController(context: context)

        super.init(nibName: nil, bundle: nil)
    }

    public required init?(coder aDecoder: NSCoder) {
        fatalError("Not implemented")
    }

    override open func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .darkGray
        view.addSubview(photoViewControllerContainer)
        view.addSubview(toolControlsContainer)
        view.addSubview(toolBar)

        setup()
        makeConstraints()
    }

    deinit {
        context.stateStore.unsubscribeSubscriber(with: id)
    }

    override open func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        changeAppearenceOfTools(for: photoViewController.mode)
        updateFiltersPhoto()
    }

    override open var prefersStatusBarHidden: Bool {
        return true
    }

    public func setImage(_ image: UIImage) {
        photoViewController.originalPhoto = image
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

    private func changeAppearenceOfTools(for mode: EditMode) {
        switch mode {
        case .crop:
            toolControlsConstainerTop?.update(offset: 0)

        case .filter:
            toolControlsConstainerTop?.update(offset: -toolControlsContainer.bounds.height)

        case .normal:
            break
        }
    }

    private func setup() {
        add(fullscreenChild: photoViewController, in: photoViewControllerContainer)
        add(fullscreenChild: filtersCollectionViewController, in: toolControlsContainer)

        context.stateStore.bindSubscriber(with: id) { [weak self] state in
            self?.changeAppearenceOfTools(for: state.value.editMode)
            self?.photoViewController.mode = state.value.editMode
        }
    }

    private func updateFiltersPhoto() {
        guard let photo = photoViewController.cropedOriginal else {
            return
        }

        DispatchQueue.global().async { [weak self] in
            let rect = photo.size.applying(CGAffineTransform(scaleX: 0.2, y: 0.2))
            let pht = photo.resizeVI(size: rect)

            DispatchQueue.main.async {
                self?.filtersCollectionViewController.image = pht
            }
        }
    }

    private lazy var filtersCollectionViewController: FiltersCollectionViewController = {
        let filters = Array(AppFilters.allCases).compactMap { CIFilter(name: $0.rawValue) }
        let controller = FiltersCollectionViewController(context: context, filters: filters)

        controller.delegate = self
        controller.view.backgroundColor = .lightGray

        return controller
    }()

    private lazy var toolBar: Toolbar = {
        let barItems = [
            BarButtonItem(title: "Crop", image: nil),
            BarButtonItem(title: "Filter", image: nil),
            BarButtonItem(title: "Add Sticker", image: nil)
        ]
        let toolbar = Toolbar(frame: .zero, barItems: barItems)
        toolbar.delegate = self
        toolbar.backgroundColor = .white

        return toolbar
    }()

    private let context: AppContext
    private var photoViewController: PhotoViewController
    private let toolControlsContainer = UIView()
    private let photoViewControllerContainer = UIView()
    private var toolControlsConstainerTop: Constraint?
}

extension SceneController: ToolbarDelegate {
    public func toolbar(_ toolbar: Toolbar, itemTapped: BarButtonItem) {
        if itemTapped.tag == 2 {
            // FIXME: add stickers mode
            // Current.stateStore.state.value.editMode = .stickers
        } else if itemTapped.tag == 1 {
            updateFiltersPhoto()
            context.stateStore.state.value.editMode = .filter

        } else if itemTapped.tag == 0 {
            context.stateStore.state.value.editMode = .crop
        }
    }
}

extension SceneController: FiltersCollectionViewControllerDelegate {
    public func filtersCollectionViewController(_ controller: FiltersCollectionViewController, didSelectFilter filter: EditFilter) {
        context.photoEditService.asyncApplyFilter(filter, to: photoViewController.originalPhoto!) { [weak self] image in
            guard let image = image else {
                return
            }

            self?.photoViewController.setPhoto(image)
        }
    }
}
