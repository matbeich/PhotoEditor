//
// Copyright © 2018 Dimasno1. All rights reserved. Product: PhotoEditor
//

import UIKit

class SceneController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .darkGray

        view.addSubview(cropView)
        view.addGestureRecognizer(testGestureRecognizer)
        testGestureRecognizer.addTarget(self, action: #selector(changeSize(with:)))
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

    var changingCorner: Corner?
    private let testGestureRecognizer = UIPanGestureRecognizer()
    let cropView = CropView(frame: CGRect(x: 50, y: 50, width: 300, height: 300), grid: Grid(numberOfRows: 5, numberOfColumns: 5))
    private let toolBar = ToolBar()
    private let toolControlsContainer = UIView()
//    private let photoViewController = PhotoViewController()
}
