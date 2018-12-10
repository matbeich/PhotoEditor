//
// Copyright © 2018 Dimasno1. All rights reserved. Product: PhotoEditor
//

import UIKit

public final class PhotoViewController: UIViewController {
    public var originalPhoto: UIImage? {
        didSet {
            guard let photo = originalPhoto else {
                return
            }

            editsViewController.set(photo)
        }
    }

    public var relativeCropZone: CGRect? {
        guard let originalSize = originalPhoto?.size else {
            return nil
        }
        
        return CGRect(x: editsViewController.visibleRect.origin.x / originalSize.width,
                      y: editsViewController.visibleRect.origin.y / originalSize.height,
                      width: editsViewController.visibleRect.width / originalSize.width,
                      height: editsViewController.visibleRect.height / originalSize.height
        )
    }

    public var cropedOriginal: UIImage? {
        return originalPhoto?.cropedZone(editsViewController.visibleRect)
    }

    public var mode: EditMode = .crop {
        didSet {
            editsViewController.mode = mode
        }
    }

    public init(context: AppContext) {
        self.context = context

        super.init(nibName: nil, bundle: nil)
    }

    public required init?(coder aDecoder: NSCoder) {
        fatalError("Not implememnted")
    }

    override public func viewDidLoad() {
        super.viewDidLoad()

        let panGestureRecognizer = UIPanGestureRecognizer()
        panGestureRecognizer.addTarget(self, action: #selector(changeCropViewFrame(with:)))

        setup()
        view.addGestureRecognizer(panGestureRecognizer)
        add(safeAreaChild: editsViewController, in: view)
    }

    public func setPhoto(_ photo: UIImage) {
        editsViewController.set(photo)
    }

    public func restoreCropedRect(fromRelative rect: CGRect) {
        editsViewController.restoreCropedRect(fromRelative: rect)
    }

    private func setup() {
        editsViewController.set(originalPhoto ?? UIImage())

        context.stateStore.addSubscriber(with: id) { [weak self] state in
            if state.value.editMode != .crop {
                self?.editsViewController.saveCropedRect()
            }
        }
    }

    @objc public func changeCropViewFrame(with recognizer: UIPanGestureRecognizer) {
        switch recognizer.state {
        case .began:
            changingCorner = editsViewController.canCrop ? editsViewController.cropViewCorner(at: recognizer.location(in: view)) : nil

        case .changed:
            guard let corner = changingCorner else {
                return
            }

            let translation = recognizer.translation(in: view)
            recognizer.setTranslation(.zero, in: view)

            editsViewController.showMask()
            editsViewController.changeCropViewFrame(using: corner, translation: translation)

        case .ended, .cancelled, .failed:
            if changingCorner != nil {
                editsViewController.saveCropedRect()
                editsViewController.fitCropView()
                editsViewController.fitSavedRectToCropView()
                editsViewController.hideMask()

                changingCorner = nil
            }

        default: break
        }
    }

    deinit {
        context.stateStore.unsubscribeSubscriber(with: id)
    }

    private let context: AppContext
    private var changingCorner: Corner?
    private let editsViewController = EditsViewController()
}
