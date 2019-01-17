//
// Copyright © 2018 Dimasno1. All rights reserved. Product:PhotoEditor
//

import Foundation
import Utils

public final class GeometryCalculator {

    public init() {}

    public func sizeOfRectFittedInBoxWithSize(_ size: CGSize, rotationAngle angle: CGFloat) -> CGSize {
        let angle = angle.magnitude.inRadians()
        let x = 1 / ((cos(angle) * cos(angle)) - (sin(angle) * sin(angle))) * (size.width * cos(angle) - size.height * sin(angle))
        let y = 1 / ((cos(angle) * cos(angle)) - (sin(angle) * sin(angle))) * (-size.width * sin(angle) + size.height * cos(angle))

        return CGSize(width: x.rounded(), height: y.rounded())
    }

    public func boundingBox(of frame: CGRect, convertedToOriginalFrameOfTransformedView view: UIView) -> CGRect {
        let scale = view.transform.scale.x
        let angle = view.transform.rotation.magnitude

        let rotatedCenter = positionOfPoint(
            frame.center,
            afterRotationOfRect: CGRect(origin: .zero, size: view.bounds.size),
            byAngle: view.transform.rotation.inDegrees()
        )

        let transformedSize = CGSize(width: view.bounds.width * scale,
                                     height: view.bounds.height * scale)

        let distanceToPointFromCenter = CGPoint(x: rotatedCenter.x - (view.bounds.width / 2),
                                                y: rotatedCenter.y - (view.bounds.height / 2))

        let positionInTransformed = CGPoint(x: ((transformedSize.width / 2) + distanceToPointFromCenter.x) / scale,
                                            y: ((transformedSize.height / 2) + distanceToPointFromCenter.y) / scale)

        let size = boundingBoxOfRectWithSize(frame.size, rotatedByAngle: angle.inDegrees()) / scale

        let origin = CGPoint(
            x: positionInTransformed.x - size.width / 2,
            y: positionInTransformed.y - size.height / 2)

        return CGRect(origin: origin, size: size)
    }

    public func boundingBoxOfRectWithSize(_ size: CGSize, rotatedByAngle angle: CGFloat) -> CGSize {
        let angle = angle.inRadians().magnitude

        let width = cos(angle) * size.width + sin(angle) * size.height
        let height = sin(angle) * size.width + cos(angle) * size.height

        return CGSize(width: width, height: height)
    }

    public func focusedPoint(by scrollView: UIScrollView) -> CGPoint {
        let x = ((scrollView.bounds.width / 2) + scrollView.contentOffset.x) / scrollView.contentSize.width
        let y = ((scrollView.bounds.height / 2) + scrollView.contentOffset.y) / scrollView.contentSize.height

        return CGPoint(x: x, y: y)
    }

    func positionOfPoint(_ point: CGPoint, afterRotationOfRect rect: CGRect, byAngle angle: CGFloat) -> CGPoint {
        let center = CGPoint(x: rect.maxX - (rect.width / 2),
                             y: rect.maxY - (rect.height / 2))

        guard point != center else {
            return point
        }

        let width: CGFloat = (point.x - center.x)
        let height: CGFloat = (point.y - center.y)

        let vector: CGFloat = sqrt(pow(width, 2) + pow(height, 2))
        let alpha = atan2(width, height).inDegrees()
        let beta = angle + alpha

        let x = sin(beta.inRadians()) * vector
        let y = cos(beta.inRadians()) * vector

        return CGPoint(x: x + center.x, y: y + center.y)
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
        let divider = cos(alpha) < .ulpOfOne ? 1 : cos(alpha)

        let a = view.bounds.width / divider

        let width = cos(beta) * (view.bounds.height - sin(alpha) * a) + a
        let height = ((view.bounds.height / tan(alpha)) + view.bounds.width) * sin(alpha)

        let heightScale = height / image.size.height
        let widthScale = width / image.size.width

        return max(heightScale, widthScale)
    }
}
