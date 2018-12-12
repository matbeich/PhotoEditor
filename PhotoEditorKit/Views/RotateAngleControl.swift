//
// Copyright © 2018 Dimasno1. All rights reserved. Product:PhotoEditor
//

import UIKit

public final class RotateAngleControl: UIControl {
    public var angle: CGFloat {
        didSet {
            sendActions(for: .valueChanged)
        }
    }

    public init(startAngle: CGFloat = 0, frame: CGRect = .zero) {
        self.angle = startAngle
        super.init(frame: frame)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setup() {
        let panGestureRecognizer = UIPanGestureRecognizer(
            target: self,
            action: #selector(rotateControlWithRecognizer)
        )

        addGestureRecognizer(panGestureRecognizer)
    }

    @objc private func rotateControlWithRecognizer(_ recognizer: UIPanGestureRecognizer) {
        switch recognizer.state {
        case .began:
            print("yo")

        case .changed:
            let angle = recognizer.translation(in: self).x.inRadians()
            let transform = CGAffineTransform.identity
            let rotating = transform.rotated(by: angle)

            controlView.layer.setAffineTransform(rotating)
        default:
            break
        }
    }

    private lazy var controlView: UIView = {
        let view = UIView()
//        view.bounds.width = bounds.width

        return view
    }()
}
