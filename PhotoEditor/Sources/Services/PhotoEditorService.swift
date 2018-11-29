//
// Copyright © 2018 Dimasno1. All rights reserved. Product:PhotoEditor
//

import CoreImage
import UIKit

typealias EditCallback = (UIImage?) -> Void

protocol EditFilter {
    var name: String { get }
    func applied(to image: CIImage, in context: CIContext, withOptions options: [String: Any]) -> CGImage?
}

extension CIFilter: EditFilter {
    func applied(to image: CIImage, in context: CIContext, withOptions options: [String: Any]) -> CGImage? {
        setValue(image, forKey: kCIInputImageKey)
        options.forEach { setValue($0.value, forKey: $0.key) }

        guard let outputImg = outputImage, let cgResult = context.createCGImage(outputImg, from: image.extent) else {
            return nil
        }

        return cgResult
    }
}

final class PhotoEditorService {
    init(options: [CIContextOption: Any]? = [.useSoftwareRenderer: false]) {
        self.context = CIContext(options: options)
    }

    func cropeZone(_ zone: CGRect, of image: UIImage) -> UIImage? {
        return image.cropedZone(zone)
    }

    func asyncApplyFilter(_ filter: EditFilter, to image: UIImage, with callback: @escaping EditCallback) {
        DispatchQueue.global().async { [weak self] in
            let img = self?.applyFilter(filter, to: image)

            DispatchQueue.main.async {
                callback(img)
            }
        }
    }

    func applyFilter(_ filter: EditFilter, to image: UIImage, withOptions options: [String: Any] = [:]) -> UIImage? {
        guard let ciImage = CIImage(image: image) else {
            return nil
        }

        return filter.applied(to: ciImage, in: context, withOptions: options).flatMap { UIImage(cgImage: $0) }
    }

    func resize(_ image: UIImage, to size: CGSize, callback: @escaping EditCallback) {
        guard let image = image.cgImage else {
            callback(nil)
            return
        }

        DispatchQueue.global().async {
            let scale = min(size.width / CGFloat(image.size.width),
                            size.height / CGFloat(image.size.height))

            let size = CGSize(width: CGFloat(image.size.width) * scale,
                              height: CGFloat(image.size.height) * scale)

            let renderer = UIGraphicsImageRenderer(size: size)
            let img = renderer.image {
                $0.cgContext.translateBy(x: 0, y: size.height)
                $0.cgContext.scaleBy(x: 1.0, y: -1.0)
                $0.cgContext.draw(image, in: CGRect(origin: .zero, size: size))
            }

            DispatchQueue.main.async {
                callback(img)
            }
        }
    }

    // FIXME: Add logic

    func changeColor(of image: UIImage, withValue value: CGFloat) -> UIImage? {
        return nil
    }

    // FIXME: Add logic

    func changedBrightness(of image: UIImage, withValue value: CGFloat) -> UIImage? {
        return nil
    }

    // FIXME: Add logic

    func rotateImage(_ image: UIImage, byDegrees degrees: CGFloat, clockwise: Bool) -> UIImage? {
        return nil
    }

    private let context: CIContext
}

extension UIImage {
    func cropedZone(_ zone: CGRect) -> UIImage? {
        guard let cutImageRef = cgImage?.cropping(to: zone) else {
            return nil
        }

        return UIImage(cgImage: cutImageRef)
    }
}
