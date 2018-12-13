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
    public init(circle: DottedNumberedCircle, frame: CGRect) {
        self.circle = circle
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

    private let circle: DottedNumberedCircle
}
