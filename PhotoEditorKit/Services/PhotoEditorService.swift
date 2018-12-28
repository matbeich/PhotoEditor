//
// Copyright © 2018 Dimasno1. All rights reserved. Product:PhotoEditor
//

import UIKit

public typealias EditCallback = (UIImage?) -> Void

public final class PhotoEditorService {
    public init(options: [CIContextOption: Any]? = [.useSoftwareRenderer: false]) {
        self.context = CIContext(options: options)
    }

    public func cropeZone(_ zone: CGRect, of image: UIImage) -> UIImage? {
        return image.cropedZone(zone)
    }

    public func asyncApplyFilter(_ filter: EditFilter, to image: UIImage, with callback: @escaping EditCallback) {
        DispatchQueue.global().async { [weak self] in
            let img = self?.applyFilter(filter, to: image)

            DispatchQueue.main.async {
                callback(img)
            }
        }
    }

    public func applyFilter(_ filter: EditFilter, to image: UIImage, withOptions options: [String: Any] = [:]) -> UIImage? {
        guard let ciImage = CIImage(image: image) else {
            return nil
        }

        return filter.applied(to: ciImage, in: context, withOptions: options).flatMap { UIImage(cgImage: $0) }
    }

    public func rotateImage(_ image: UIImage, byDegrees degrees: CGFloat) -> UIImage? {
        guard let img = image.fixOrientation(), degrees.isInRange(-90 ..< 91) else {
            assertionFailure("Angle must be in range from -90 to 90.")
            return nil
        }

        let angle = degrees.inRadians()
        let clockwise = degrees > 0
        let imageSize = calculator.boundingBoxSize(of: CGRect(origin: .zero, size: img.size), forRotationAngle: degrees)
        let imgRenderer = UIGraphicsImageRenderer(size: imageSize)

        let translation = CGPoint(x: clockwise ? sin(angle) * img.size.height : 0,
                                  y: clockwise ? 0 : -(sin(angle) * img.size.width))

        return imgRenderer.image { ctx in
            ctx.cgContext.translateBy(x: translation.x, y: translation.y)
            ctx.cgContext.rotate(by: angle)

            img.draw(in: CGRect(origin: .zero, size: img.size))
        }
    }


    public func drawImage(_ image: UIImage, with size: CGSize, rect: CGRect) -> UIImage? {
        guard let img = image.fixOrientation() else {
            return nil
        }

        let imgRenderer = UIGraphicsImageRenderer(size: size)

        return imgRenderer.image { ctx in
            ctx.cgContext.stroke(CGRect(origin: .zero, size: size))
            img.draw(in: rect)
        }
    }

    private let context: CIContext
    private let calculator = GeometryCalculator()
}

public extension FloatingPoint {
    func isInRange(_ range: Range<Self>) -> Bool {
        return range.contains(self)
    }
}
