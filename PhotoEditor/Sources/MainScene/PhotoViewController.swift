//
// Copyright © 2018 Dimasno1. All rights reserved. Product: PhotoEditor
//

import UIKit

class PhotoViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        let panGestureRecognizer = UIPanGestureRecognizer()

        let grid = Grid(numberOfRows: 3, numberOfColumns: 3)
        cropView = CropView(frame: view.frame, grid: grid)

        view.addSubview(photoView)
        view.addSubview(cropView)
        view.addGestureRecognizer(panGestureRecognizer)

        makeConstraints()

        panGestureRecognizer.addTarget(self, action: #selector(changeSize(with:)))
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        cropView.frame = view.frame
        cropView.allowedBounds = view.frame.inset(by: UIEdgeInsets(repeated: 10))
        print(view.frame)
        print(cropView.allowedBounds)
    }

    @objc func changeSize(with recognizer: UIPanGestureRecognizer) {
        switch recognizer.state {
        case .began:
            changingCorner = cropView.cornerPosition(at: recognizer.location(in: cropView))
        case .changed:
            guard let corner = changingCorner else {
                return
            }

            let translation = recognizer.translation(in: view)
            recognizer.setTranslation(.zero, in: view)

            cropView.changeFrame(using: corner, translation: translation)
        case .ended, .cancelled, .failed:
            changingCorner = nil
        default: break
        }
    }

    private func makeConstraints() {
        photoView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    private var cropView = CropView(frame: .zero)
    private var changingCorner: Corner?
    private let photoView = PhotoView()
}
