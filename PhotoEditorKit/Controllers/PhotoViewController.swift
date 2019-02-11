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

            setPhoto(photo)
        }
    }

    public var cutArea: CGRect {
        return editsViewController.relativeCutRect
    }

    public var angle: CGFloat {
        return editsViewController.edits.imageRotationAngle ?? 0
    }

    public var mode: EditMode = .crop {
        didSet {
            editsViewController.mode = mode
        }
    }

    public init(context: AppContext) {
        self.context = context
        self.editsViewController = EditsViewController(context: context)

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
        context.stateStore.addSubscriber(with: id) { [weak self] state in
            if state.value.editMode != .crop {
                self?.editsViewController.saveCropedAppearence()
            }
        }
    }

    public func rotateImage(by angle: CGFloat) {
        editsViewController.showMask()
        editsViewController.rotatePhoto(by: angle)
    }

    @objc public func changeCropViewFrame(with recognizer: UIPanGestureRecognizer) {
        switch recognizer.state {
        case .began:
            let point = view.convert(recognizer.location(in: view), to: editsViewController.view)
            changingCorner = context.stateStore.state.value.editMode.state.showCrop ? editsViewController.cropViewCorner(at: point) : nil

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
                editsViewController.saveCropedAppearence()
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
    private let editsViewController: EditsViewController
}
