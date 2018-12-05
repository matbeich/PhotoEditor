//
// Copyright © 2018 Dimasno1. All rights reserved. Product: PhotoEditor
//

import UIKit

public class PhotoViewController: UIViewController {
    public var originalPhoto: UIImage? {
        didSet {
            guard let photo = originalPhoto else {
                return
            }

            photoEditsView.set(photo)
        }
    }

    public var cropedOriginal: UIImage? {
        return originalPhoto?.cropedZone(photoEditsView.visibleRect)
    }

    public var mode: EditMode = .crop {
        didSet {
            photoEditsView.mode = mode
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
        panGestureRecognizer.addTarget(self, action: #selector(changeSize(with:)))

        setup()
        view.addSubview(photoEditsView)
        view.addGestureRecognizer(panGestureRecognizer)
        makeConstraints()
    }

    public func setPhoto(_ photo: UIImage) {
        photoEditsView.set(photo)
    }

    private func setup() {
        photoEditsView.set(originalPhoto ?? UIImage())

        context.stateStore.addSubscriber(with: id) { [weak self] state in
            if state.value.editMode != .crop {
                self?.photoEditsView.saveCropedRect()
            }
        }
    }

    private func makeConstraints() {
        photoEditsView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    @objc public func changeSize(with recognizer: UIPanGestureRecognizer) {
        switch recognizer.state {
        case .began:
            changingCorner = photoEditsView.canCrop ? photoEditsView.cropViewCorner(at: recognizer.location(in: view)) : nil

        case .changed:
            guard let corner = changingCorner else {
                return
            }

            let translation = recognizer.translation(in: view)
            recognizer.setTranslation(.zero, in: view)

            photoEditsView.showMask()
            photoEditsView.changeCropViewFrame(using: corner, translation: translation)
            photoEditsView.saveCropedRect()

        case .ended, .cancelled, .failed:
            if changingCorner != nil {
                photoEditsView.fitCropView()
                photoEditsView.fitSavedRectToCropView()
                photoEditsView.hideMask()

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
    private let photoEditsView = PhotoEditsView()
}
