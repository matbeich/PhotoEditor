//
// Copyright © 2018 Dimasno1. All rights reserved. Product:PhotoEditor
//

import Foundation


final class GeometryCalculator {
    
    public func boundingBoxSize(of frame: CGRect, rotatedByAngle angle: CGFloat) -> CGSize {
        let width = cos(angle) * frame.width + sin(angle) * frame.height
        let height = sin(angle) * frame.width + cos(angle) * frame.height

        return CGSize(width: width, height: height)
    }

    public func boundingBox(of frame: CGRect, inBoundsOf trasformedView: UIView) -> CGRect {
        let scale = trasformedView.transform.scale.x
        let angle = trasformedView.transform.rotation.magnitude
        
        let frameHeight = frame.maxY - frame.origin.y
        let frameWidth = frame.maxX - frame.origin.x
        let width = (cos(angle) * frameWidth + sin(angle) * frameHeight) / scale
        let height = (sin(angle) * frameWidth + cos(angle) * frameHeight) / scale

        let x = frame.origin.x + (frameWidth - width) / 2
        let y = frame.origin.y + (frameHeight - height) / 2

        return CGRect(x: x, y: y, width: width, height: height)
    }

    public func fitScale(for image: UIImage, in view: UIView, rotationAngle: CGFloat) -> CGFloat {
        let alpha = rotationAngle.magnitude.inRadians()
        let beta = (90 - rotationAngle.magnitude).inRadians()

        let a = view.bounds.width / cos(alpha)
        let b = sin(alpha) * a
        let c = view.bounds.height - b
        let d = view.bounds.height / tan(alpha)

        let width = cos(beta) * c + a
        let height = (d + view.bounds.width) * sin(alpha)

        let heightScale = height / image.size.height
        let widthScale = width / image.size.width

        return max(heightScale, widthScale)
    }
}
