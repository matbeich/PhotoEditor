//
// Copyright © 2018 Dimasno1. All rights reserved. Product:PhotoEditor
//

import UIKit

public typealias EditCallback = (UIImage?) -> Void

public final class PhotoEditorService {
    public init(options: [CIContextOption: Any]? = [.useSoftwareRenderer: false]) {
        self.context = CIContext(options: options)
    }

    public func asyncApplyFilter(_ filter: AppFilter, to image: UIImage, with callback: @escaping EditCallback) {
        DispatchQueue.global().async { [weak self] in
            let img = self?.applyFilter(filter, to: image)

            DispatchQueue.main.async {
                callback(img)
            }
        }
    }

    public func asyncRotateImage(_ image: UIImage, byDegrees degrees: CGFloat, callback: @escaping EditCallback) {
        DispatchQueue.global().async { [weak self] in
            let img = self?.rotateImage(image, byDegrees: degrees)

            DispatchQueue.main.async {
                callback(img)
            }
        }
    }

    public func applyFilter(_ filter: AppFilter, to image: UIImage) -> UIImage? {
        guard let ciImage = CIImage(image: image), let ciFilter = CIFilter(name: filter.specs.name, parameters: [:]) else {
            return nil
        }

        return ciFilter.applied(to: ciImage, in: context, withOptions: filter.specs.parameters).flatMap { UIImage(cgImage: $0) }
    }

    public func rotateImage(_ image: UIImage, byDegrees degrees: CGFloat) -> UIImage? {
        guard degrees.isInRange(-90 ..< 91) else {
            assertionFailure("Angle must be in range from -90 to 90.")
            return nil
        }

        let angle = degrees.inRadians()
        let clockwise = degrees > 0
        let imageSize = calculator.boundingBoxOfRectWithSize(image.size, rotatedByAngle: degrees)
        let imgRenderer = UIGraphicsImageRenderer(size: imageSize)

        let translation = CGPoint(x: clockwise ? sin(angle) * image.size.height : 0,
                                  y: clockwise ? 0 : -(sin(angle) * image.size.width))

        return imgRenderer.image { ctx in
            ctx.cgContext.translateBy(x: translation.x, y: translation.y)
            ctx.cgContext.rotate(by: angle)

            image.draw(in: CGRect(origin: .zero, size: image.size))
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

private extension CIFilter {
    convenience init?(appFilter: AppFilter) {
        self.init(name: appFilter.specs.name, parameters: appFilter.specs.parameters)
    }
}

extension PhotoEditorService {
    public func applyEdits(_ edits: Edits, to image: UIImage, callback: @escaping (Bool, UIImage?) -> Void) {
        var modifiedImage: UIImage? = image

        DispatchQueue.global().async { [weak self] in
            guard let self = self else {
                callback(false, nil)
                return
            }

            if edits.imageRotationAngle != 0, let image = modifiedImage?.zoom(scale: 1.0) {
                modifiedImage = self.rotateImage(image, byDegrees: edits.imageRotationAngle)
            }

            let rotatedImageFrame = CGRect(origin: .zero, size: modifiedImage?.size ?? .zero)

            if let cropZone = edits.relativeCutFrame?.absolute(in: rotatedImageFrame) {
                modifiedImage = modifiedImage?.cropedZone(cropZone)
            }

            if let filter = edits.filter, let editingImage = modifiedImage {
                self.asyncApplyFilter(filter, to: editingImage) { image in
                    callback(image != nil, image)
                }
            } else {
                DispatchQueue.main.async {
                    callback(true, modifiedImage)
                }
            }
        }
    }
}
