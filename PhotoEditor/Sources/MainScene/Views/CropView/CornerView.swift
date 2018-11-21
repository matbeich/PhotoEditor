//
// Copyright © 2018 Dimasno1. All rights reserved. Product:PhotoEditor
//

import UIKit

enum Corner {
    case topLeft
    case topRight
    case bottomLeft
    case bottomRight
}

class CornerView: UIView {
    let corner: Corner

    init(frame: CGRect = .zero, corner: Corner) {
        self.corner = corner

        super.init(frame: frame)
        setPath()
        layer.addSublayer(shapeLayer)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        shapeLayer.frame = bounds
        setPath()
    }

    private func setPath() {
        let path = UIBezierPath()

        var startPoint: CGPoint
        var endPoint: CGPoint
        var controlPoint: CGPoint

        switch corner {
        case .topLeft:
            startPoint = CGPoint(x: bounds.maxX, y: 0)
            controlPoint = .zero
            endPoint = CGPoint(x: 0, y: bounds.maxY)
        case .topRight:
            startPoint = .zero
            controlPoint = CGPoint(x: bounds.maxX, y: 0)
            endPoint = CGPoint(x: bounds.maxX, y: bounds.maxY)
        case .bottomLeft:
            startPoint = .zero
            controlPoint = CGPoint(x: 0, y: bounds.maxY)
            endPoint = CGPoint(x: bounds.maxX, y: bounds.maxY)
        case .bottomRight:
            startPoint = CGPoint(x: bounds.maxX, y: 0)
            controlPoint = CGPoint(x: bounds.maxX, y: bounds.maxY)
            endPoint = CGPoint(x: 0, y: bounds.maxY)
        }

        path.move(to: startPoint)
        path.addLine(to: controlPoint)
        path.addLine(to: endPoint)

        shapeLayer.path = path.cgPath
    }

    private var shapeLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.lineWidth = 3
        layer.fillColor = nil
        layer.strokeColor = UIColor.white.cgColor

        return layer
    }()
}
