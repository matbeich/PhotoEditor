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
    func square(at point: CGPoint, with size: CGSize)
}

extension CGContext: Renderer {
    public func square(at point: CGPoint, with size: CGSize) {
        stroke(CGRect(origin: point, size: size))
    }
}
