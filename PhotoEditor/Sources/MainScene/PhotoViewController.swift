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

        view.addSubview(photoView)
        view.addSubview(cropView)
        view.addGestureRecognizer(panGestureRecognizer)
        makeConstraints()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        cropView.frame = view.frame
        cropView.allowedBounds = view.frame.inset(by: UIEdgeInsets(top: UIApplication.shared.statusBarFrame.height,
                                                                   left: 10,
                                                                   bottom: 10,
                                                                   right: 10))
    }

    private func setup() {
        let grid = Grid(numberOfRows: 3, numberOfColumns: 3)

        cropView = CropView(frame: view.frame, grid: grid)
        cropView.showGrid = false

        photoView.set(UIImage(named: "test.png")!)
    }

    @objc func changeSize(with recognizer: UIPanGestureRecognizer) {
        switch recognizer.state {
        case .began:
            changingCorner = cropView.cornerPosition(at: recognizer.location(in: cropView))
            cropView.showGrid = true
        case .changed:
            guard let corner = changingCorner else {
                return
            }

            let translation = recognizer.translation(in: view)
            recognizer.setTranslation(.zero, in: view)

            cropView.changeFrame(using: corner, translation: translation)
        case .ended, .cancelled, .failed:
            changingCorner = nil
            cropView.showGrid = false
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
