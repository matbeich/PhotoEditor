//
// Copyright © 2018 Dimasno1. All rights reserved. Product: PhotoEditor
//

import UIKit

class PhotoViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()

        let panGestureRecognizer = UIPanGestureRecognizer()
        panGestureRecognizer.addTarget(self, action: #selector(changeSize(with:)))

        view.addSubview(photoEditsView)
        view.addGestureRecognizer(panGestureRecognizer)
        makeConstraints()
    }

    private func setup() {
        photoEditsView.set(UIImage(named: "test.png")!)
    }

    private func makeConstraints() {
        photoEditsView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    @objc func changeSize(with recognizer: UIPanGestureRecognizer) {
        switch recognizer.state {
        case .began:
            changingCorner = photoEditsView.cropViewCorner(at: recognizer.location(in: view))

        case .changed:
            guard let corner = changingCorner else {
                return
            }

            let translation = recognizer.translation(in: view)
            recognizer.setTranslation(.zero, in: view)

            photoEditsView.state = .crop
            photoEditsView.changeCropViewFrame(using: corner, translation: translation)
            photoEditsView.saveCropedRect()

        case .ended, .cancelled, .failed:
            if changingCorner != nil {
                photoEditsView.fitCropView()
                photoEditsView.fitSavedRectToCropView()
                photoEditsView.state = .normal

                changingCorner = nil
            }

        default: break
        }
    }

    private var changingCorner: Corner?
    private let photoEditsView = PhotoEditsView()
}
