//
// Copyright © 2018 Dimasno1. All rights reserved. Product:PhotoEditor
//

import Foundation

public struct DottedNumberedCircle {
    public var numberOfDots: Int
    public var dotRadius: CGFloat

    public init(numberOfDots: Int, dotRadius: CGFloat) {
        self.numberOfDots = numberOfDots
        self.dotRadius = dotRadius
    }

    public func draw(with renderer: Renderer, in rect: CGRect) {
        let center = CGPoint(x: rect.width / 2, y: rect.height / 2)
        let radius = (min(rect.width, rect.height) / 2) * 0.9

        for dotNumber in 1...numberOfDots {
            let angle = 360 * CGFloat(dotNumber) / CGFloat(numberOfDots)
            let xOffset = radius * cos(angle.inRadians())
            let yOffset = radius * sin(angle.inRadians())
            let lableAngle = atan2(xOffset, -yOffset)
            let point = CGPoint(x: center.x + xOffset, y: center.y - yOffset)
            let labelPoint = CGPoint(x: center.x + xOffset * 0.95, y: center.y - yOffset * 0.95)
            let renderRadius = dotNumber % 5 == 0 ? dotRadius * 2 : dotRadius
            let labelTitle = dotNumber % 10 == 0 ? "\(Int(lableAngle.inDegrees().rounded()))" : ""

            renderer.dot(at: point, with: renderRadius)
            renderer.text(labelTitle, at: labelPoint, transformAngle: lableAngle)
        }
    }
}

