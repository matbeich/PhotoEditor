//
// Copyright © 2018 Dimasno1. All rights reserved. Product:PhotoEditor
//

import UIKit

final class DottedNumberedCircleView: UIView {
    var dotsColor: UIColor = .darkGray {
        didSet {
            setNeedsDisplay()
        }
    }

    var dotsNumber: Int {
        didSet {
            update()
        }
    }

    var dotsRadius: CGFloat {
        didSet {
            update()
        }
    }

    public init(circle: DottedNumberedCircle, frame: CGRect) {
        self.circle = circle
        self.dotsNumber = circle.numberOfDots
        self.dotsRadius = circle.dotRadius
        super.init(frame: frame)

        backgroundColor = .clear
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else {
            return
        }

        context.setFillColor(dotsColor.cgColor)
        circle.draw(with: context, in: rect)
    }

    private func update() {
        circle = DottedNumberedCircle(
            numberOfDots: dotsNumber,
            dotRadius: dotsRadius
        )

        setNeedsDisplay()
    }

    private var circle: DottedNumberedCircle
}
