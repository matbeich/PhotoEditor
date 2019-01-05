//
// Copyright © 2018 Dimasno1. All rights reserved. Product: PhotoEditor
//

import Photos
import PhotosUI
import SnapKit
import UIKit

open class SceneController: UIViewController {
    public var selectedFilter: EditFilter? {
        didSet {
            applyFilter(selectedFilter)
        }
    }

    public var currentPhoto: UIImage? {
        return photoViewController.originalPhoto
    }

    public var cutArea: CGRect {
        return photoViewController.cutArea
    }

    public var angle: CGFloat? {
        return photoViewController.angle
    }

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
        view.backgroundColor = .white
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

    public func restoreCropedRect(fromRelative rect: CGRect) {
        photoViewController.restoreCropedRect(fromRelative: rect)
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

    @objc private func rotateImage(using control: RotateAngleControl) {
        photoViewController.rotateImage(by: control.angle)
    }

    private func changeAppearenceOfTools(for mode: EditMode) {
        switch mode {
        case .crop:
            filtersCollectionViewController.view.removeFromSuperview()
            filtersCollectionViewController.removeFromParent()

            toolControlsConstainerTop?.update(offset: -toolControlsContainer.bounds.height)
            toolControlsContainer.addSubview(rotateControl)

            rotateControl.snp.remakeConstraints { make in
                make.edges.equalToSuperview()
            }

            toolControlsContainer.addSubview(rotateControl)

        case .filter:
            rotateControl.snp.removeConstraints()
            rotateControl.removeFromSuperview()

            add(fullscreenChild: filtersCollectionViewController, in: toolControlsContainer)

        case .normal:
            break
        }
    }

    private func setup() {
        rotateControl.setDotsColor(.lightGray)
        rotateControl.maxAngle = 90
        rotateControl.minAngle = -90
        rotateControl.addTarget(self, action: #selector(rotateImage), for: .valueChanged)
        add(fullscreenChild: photoViewController, in: photoViewControllerContainer)
        add(fullscreenChild: filtersCollectionViewController, in: toolControlsContainer)

        context.stateStore.bindSubscriber(with: id) { [weak self] state in
            self?.changeAppearenceOfTools(for: state.value.editMode)
            self?.photoViewController.mode = state.value.editMode
        }
    }

    #warning("set filters")
    private func updateFiltersPhoto() {
//        guard let photo = photoViewController.cropedOriginal else {
//            return
//        }
//
//        DispatchQueue.global().async { [weak self] in
//            let rect = photo.size.applying(CGAffineTransform(scaleX: 0.2, y: 0.2))
//            let pht = photo.resizeVI(size: rect)
//
//            DispatchQueue.main.async {
//                self?.filtersCollectionViewController.image = pht
//            }
//        }
    }

    private lazy var filtersCollectionViewController: FiltersCollectionViewController = {
        let filters = Array(AppFilter.allCases).compactMap { CIFilter(
            name: $0.specs.name,
            parameters: $0.specs.parameters)
        }
        
        let controller = FiltersCollectionViewController(context: context, filters: filters)

        controller.delegate = self
        controller.view.backgroundColor = view.backgroundColor

        return controller
    }()

    private lazy var toolBar: Toolbar = {
        let barItems = [
            BarButtonItem(title: "Crop", image: nil),
            BarButtonItem(title: "Filters", image: nil),
            BarButtonItem(title: "Preview", image: nil)
        ]
        let toolbar = Toolbar(frame: .zero, barItems: barItems)
        toolbar.delegate = self
        toolbar.backgroundColor = .white

        return toolbar
    }()

    private func applyFilter(_ filter: EditFilter?) {
        guard let originalPhoto = photoViewController.originalPhoto, let filter = filter else {
            return
        }

        context.photoEditService.asyncApplyFilter(filter, to: originalPhoto) { [weak self] image in
            guard let image = image else {
                return
            }

            self?.photoViewController.setPhoto(image)
        }
    }

    private let rotateControl = RotateAngleControl(startAngle: 0, frame: .zero)
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
        selectedFilter = filter
    }
}
