//
// Copyright © 2018 Dimasno1. All rights reserved. Product:PhotoEditor
//

import UIKit

public struct Grid: Drawable {
    let numberOfRows: Int
    let numberOfColumns: Int

    public init?(numberOfRows: Int, numberOfColumns: Int) {
        guard numberOfRows > 0 && numberOfColumns > 0 else {
            return nil
        }

        self.numberOfColumns = numberOfColumns
        self.numberOfRows = numberOfRows
    }

    public func draw(with renderer: Renderer, in rect: CGRect) {
        var points = [CGPoint]()
        let squareWidth = rect.width / CGFloat(numberOfColumns)
        let squareHeight = rect.height / CGFloat(numberOfRows)
        let sizeOfSquare = CGSize(width: squareWidth, height: squareHeight)

        for row in 1 ... numberOfRows {
            for column in 1 ... numberOfColumns {
                points.append(CGPoint(x: CGFloat(column - 1) * squareWidth,
                                      y: CGFloat(row - 1) * squareHeight))
            }
        }

        points.forEach { renderer.square(at: $0, with: sizeOfSquare) }
    }
}

public protocol Drawable {
    func draw(with renderer: Renderer, in rect: CGRect)
}

public protocol Renderer {
    func text(_ text: String, at point: CGPoint, transformAngle angle: CGFloat)
    func dot(at point: CGPoint, with radius: CGFloat)
    func square(at point: CGPoint, with size: CGSize)
}

extension CGContext: Renderer {
    public func text(_ text: String, at point: CGPoint, transformAngle angle: CGFloat) {
        saveGState()
        defer { restoreGState() }

        let fontSize: CGFloat = 12.0
        let size = (text as NSString).size(withAttributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: fontSize)])

        translateBy(x: point.x, y: point.y)
        rotate(by: -angle)
        text.draw(at: CGPoint(x: -size.width / 2, y: 0), withAttributes: nil)
    }
    
    public func dot(at point: CGPoint, with radius: CGFloat) {
       addArc(center: point, radius: radius, startAngle: CGFloat(0.0.inRadians()), endAngle: CGFloat.pi.inRadians(), clockwise: false)
    }

    public func square(at point: CGPoint, with size: CGSize) {
        stroke(CGRect(origin: point, size: size))
    }
}
