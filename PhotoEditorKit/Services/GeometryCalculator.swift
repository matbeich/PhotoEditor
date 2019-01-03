//
// Copyright © 2018 Dimasno1. All rights reserved. Product:PhotoEditor
//

import Foundation


public final class GeometryCalculator {

    public init() {}
    
    public func boundingBoxSize(of frame: CGRect, forRotationAngle angle: CGFloat) -> CGSize {
        let angle = angle.inRadians().magnitude

        let width = cos(angle) * frame.width + sin(angle) * frame.height
        let height = sin(angle) * frame.width + cos(angle) * frame.height

        return CGSize(width: width, height: height)
    }

    public func boundingBox(of frame: CGRect, convertedToBoundsOf trasformedView: UIView) -> CGRect {
        let scale = trasformedView.transform.scale.x
        let angle = trasformedView.transform.rotation.magnitude
        
        let frameHeight = frame.maxY - frame.origin.y
        let frameWidth = frame.maxX - frame.origin.x
        let width = (cos(angle) * frameWidth + sin(angle) * frameHeight) / scale
        let height = (sin(angle) * frameWidth + cos(angle) * frameHeight) / scale

        let x = frame.origin.x - (width - frameWidth) / 2
        let y = frame.origin.y - (height - frameHeight) / 2

        return CGRect(x: x, y: y, width: width, height: height)
    }

    public func focusedPoint(by scrollView: UIScrollView) -> CGPoint {
        let x = ((scrollView.bounds.width / 2) + scrollView.contentOffset.x) / scrollView.contentSize.width
        let y = ((scrollView.bounds.height / 2) + scrollView.contentOffset.y) / scrollView.contentSize.height

        return CGPoint(x: x, y: y)
    }

    public func boundedBoxPositionOfPoint(_ point: CGPoint, afterRotationOfRect rect: CGRect, byAngle angle: CGFloat) -> CGPoint {
        let rotatedOrigin = CGPoint(x: angle < 0 ? 0 : sin(angle.magnitude.inRadians()) * rect.height,
                                    y: angle < 0 ? sin(angle.magnitude.inRadians()) * rect.width : 0)
        
        let alpha = atan(point.y / point.x).inDegrees()
        let beta = 90 - (angle + alpha)
        let vectorToOrigin = sqrt(pow(point.x, 2) + pow(point.y, 2))

        let x = sin(beta.inRadians()) * vectorToOrigin
        let y = cos(beta.inRadians()) * vectorToOrigin

        return CGPoint(x: x + rotatedOrigin.x, y: y + rotatedOrigin.y)
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
