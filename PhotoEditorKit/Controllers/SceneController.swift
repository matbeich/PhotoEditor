//
// Copyright © 2018 Dimasno1. All rights reserved. Product: PhotoEditor
//

import Photos
import PhotosUI
import SnapKit
import UIKit

open class SceneController: UIViewController {
    public var selectedFilter: AppFilter? {
        didSet {
            applyFilter(selectedFilter)
            context.stateStore.state.value.performedEdits.filter = selectedFilter
        }
    }

    public var scenePhoto: UIImage? {
        return photoViewController.originalPhoto
    }

    public init(context: AppContext) {
        self.context = context
        self.photoViewController = PhotoViewController(context: context)

        super.init(nibName: nil, bundle: nil)
    }

    public required init?(coder aDecoder: NSCoder) {
        fatalError("Not implemented")
    }

    deinit {
        context.stateStore.unsubscribeSubscriber(with: id)
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
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

    override open func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        showTools(for: photoViewController.mode)
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

    private func showTools(for mode: EditMode) {
        switch mode {
        case .crop:
            filtersCollectionViewController.view.removeFromSuperview()
            filtersCollectionViewController.removeFromParent()

            toolControlsConstainerTop?.update(offset: -toolControlsContainer.bounds.height)
            toolControlsContainer.addSubview(rotateControl)

            rotateControl.snp.remakeConstraints { make in
                make.edges.equalToSuperview()
            }

        case .filter:
            rotateControl.snp.removeConstraints()
            rotateControl.removeFromSuperview()

            add(fullscreenChild: filtersCollectionViewController, in: toolControlsContainer)
            toolControlsConstainerTop?.update(offset: -toolControlsContainer.bounds.height)

        case .normal:
            break
        }
    }

    private func setup() {
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        rotateControl.setDotsColor(.lightGray)
        rotateControl.maxAngle = 90
        rotateControl.minAngle = -90
        rotateControl.addTarget(self, action: #selector(rotateImage), for: .valueChanged)
        add(fullscreenChild: photoViewController, in: photoViewControllerContainer)
        add(fullscreenChild: filtersCollectionViewController, in: toolControlsContainer)

        context.stateStore.bindSubscriber(with: id) { [weak self] state in
            self?.showTools(for: state.value.editMode)
            self?.photoViewController.mode = state.value.editMode
        }
    }

    private func updateFiltersPhoto() {
        photoViewController.savePerfomedEdits()
        guard let photo = scenePhoto else {
            return
        }

        let size = thumbnailSizeFor(image: photo)

        DispatchQueue.global().async { [weak self] in
            guard let pht = photo.resizeVI(size: size), let self = self else {
                return
            }

            self.context.photoEditService.applyEdits(self.context.stateStore.state.value.performedEdits, to: pht) { success, image in
                guard let photo = image , success else {
                    return
                }

                DispatchQueue.main.async {
                    self.filtersCollectionViewController.image = photo
                }
            }
        }
    }

    private func applyFilter(_ filter: AppFilter?) {
        guard let originalPhoto = photoViewController.originalPhoto, let filter = filter else {
            return
        }

        context.photoEditService.asyncApplyFilter(filter, to: originalPhoto) { [weak self] image in
            guard let image = image else {
                return
            }

            self?.photoViewController.updatePhoto(image)
        }
    }

    private func thumbnailSizeFor(image: UIImage) -> CGSize {
        let heightRatio =  image.size.height / image.size.width
        let value: CGFloat = 150.0

        return CGSize(width: value, height: value * heightRatio)
    }

    private lazy var filtersCollectionViewController: FiltersCollectionViewController = {
        let filters = Array(AppFilter.allCases)
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

    private let context: AppContext
    private var photoViewController: PhotoViewController
    private let toolControlsContainer = UIView()
    private let photoViewControllerContainer = UIView()
    private var toolControlsConstainerTop: Constraint?
    private let rotateControl = RotateAngleControl(startAngle: 0, frame: .zero)
}

extension SceneController: ToolbarDelegate {
    public func toolbar(_ toolbar: Toolbar, itemTapped: BarButtonItem) {
        switch itemTapped.tag {
        case 0:
            context.stateStore.state.value.editMode = .crop

        case 1:
            context.stateStore.state.value.editMode = .filter
            updateFiltersPhoto()

        case 2:
            #warning("add stickers mode")
            print("stickers mode not implemented yet")

        default: break
        }
    }
}

extension SceneController: FiltersCollectionViewControllerDelegate {
    public func filtersCollectionViewController(_ controller: FiltersCollectionViewController, didSelectFilter filter: AppFilter) {
        selectedFilter = filter
    }
}

extension FiltersCollectionViewController {

}
