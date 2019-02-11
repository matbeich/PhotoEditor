//
// Copyright © 2018 Dimasno1. All rights reserved. Product:PhotoEditor
//

import UIKit

public final class RotateAngleControl: UIControl {
    let maximumAlowedAngle: CGFloat
    let minimumAlowedAngle: CGFloat

    public private(set) var angle: CGFloat {
        didSet {
            keepInBounds()
            sendActions(for: .valueChanged)
        }
    }

    public var maxAngle: CGFloat {
        didSet {
            maxAngle = max(minAngle, min(maximumAlowedAngle, maxAngle))
            keepInBounds()
        }
    }

    public var minAngle: CGFloat {
        didSet {
            minAngle = min(maxAngle, max(minimumAlowedAngle, minAngle))
            keepInBounds()
        }
    }

    public init(startAngle: CGFloat = 0, frame: CGRect = .zero) {
        self.maximumAlowedAngle = 180
        self.minimumAlowedAngle = -180
        self.maxAngle = maximumAlowedAngle
        self.minAngle = minimumAlowedAngle
        self.angle = startAngle
        super.init(frame: frame)

        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func layoutSubviews() {
        super.layoutSubviews()

        numberedCircleView.bounds.size = CGSize(width: bounds.width, height: bounds.width)
        numberedCircleView.center = CGPoint(x: center.x, y: bounds.maxY - numberedCircleView.bounds.height / 2)
    }

    private func setup() {
        layer.masksToBounds = true
        backgroundColor = .clear

        let panGestureRecognizer = UIPanGestureRecognizer(
            target: self,
            action: #selector(rotateControlWithRecognizer)
        )

        addSubview(numberedCircleView)
        addGestureRecognizer(panGestureRecognizer)
        setAngle(angle)
    }

    public func setDotsNumber(_ number: Int) {
        numberedCircleView.dotsNumber = number
    }

    public func setDotsColor(_ color: UIColor) {
        numberedCircleView.dotsColor = color
    }

    public func setDotsRadius(_ radius: CGFloat) {
        numberedCircleView.dotsRadius = radius
    }

    public func rotateToAngle(_ angle: CGFloat, animated: Bool = false) {
        self.angle = angle

        if animated {
            let distance = Double((self.angle - angle).magnitude)
            let speed: Double = 30.0
            let duration: TimeInterval = distance / speed
            UIView.animate(withDuration: duration) { [weak self] in
                guard let self = self else {
                    return
                }

                self.setAngle(self.angle)
            }
        } else {
            setAngle(self.angle)
        }
    }

    @objc private func rotateControlWithRecognizer(_ recognizer: UIPanGestureRecognizer) {
        switch recognizer.state {

        case .changed, .cancelled, .ended:
            angle -= recognizer.translation(in: self).x / 5

            setAngle(angle)
            recognizer.setTranslation(.zero, in: self)
        default:
            break
        }
    }

    private func setAngle(_ angle: CGFloat) {
        let transform = CGAffineTransform.identity
        let rotating = transform.rotated(by: angle.inRadians())

        numberedCircleView.layer.setAffineTransform(rotating)
    }

    private func keepInBounds() {
        guard angle >= minAngle else {
            angle = minAngle
            return
        }

        guard angle <= maxAngle else {
            angle = maxAngle
            return
        }
    }

    private lazy var numberedCircleView: DottedNumberedCircleView = {
        let circle = DottedNumberedCircle(numberOfDots: 360, dotRadius: 0.5)

        return DottedNumberedCircleView(
            circle: circle,
            frame: CGRect(x: 0, y: 0, width: bounds.width, height: bounds.width)
        )
    }()
}
