//
// Copyright © 2018 Dimasno1. All rights reserved. Product:PhotoEditor
//

import CoreImage
import ImageIO
import UIKit

typealias EditCallback = (UIImage?) -> Void

protocol PhotoEditorServiceType {
    func resize(_ image: UIImage, to size: CGSize, callback: @escaping EditCallback)
    func cropeZone(_ zone: CGRect, of image: UIImage) -> UIImage?
    func rotateImage(_ image: UIImage, byDegrees degrees: CGFloat, clockwise: Bool) -> UIImage?
    func applyFilterNamed(_ name: String, to image: UIImage, withOptions options: [String: Any]) -> UIImage?
    func changeColor(of image: UIImage, withValue value: CGFloat) -> UIImage?
    func changedBrightness(of image: UIImage, withValue value: CGFloat) -> UIImage?
}

final class PhotoEditorService: PhotoEditorServiceType {
    init(options: [CIContextOption: Any]? = [.useSoftwareRenderer: false]) {
        self.context = CIContext(options: options)
    }

    func cropeZone(_ zone: CGRect, of image: UIImage) -> UIImage? {
        return image.cropedZone(zone)
    }

    func asyncApplyFilterNamed(_ name: String, to image: UIImage, with callback: @escaping EditCallback) {
        DispatchQueue.global().async { [weak self] in
            let img = self?.applyFilterNamed(name, to: image)

            DispatchQueue.main.async {
                callback(img)
            }
        }
    }

    func applyFilterNamed(_ name: String, to image: UIImage, withOptions options: [String: Any] = [:]) -> UIImage? {
        guard let filter = CIFilter(name: name), let ciImage = CIImage(image: image) else {
            return nil
        }

        filter.setValue(ciImage, forKey: kCIInputImageKey)
        options.forEach { filter.setValue($0.value, forKey: $0.key) }

        guard let outputImg = filter.outputImage, let cgResult = context.createCGImage(outputImg, from: ciImage.extent) else {
            return nil
        }

        return UIImage(cgImage: cgResult)
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
//                $0.cgContext.saveGState()
                $0.cgContext.translateBy(x: 0, y: size.height)
                $0.cgContext.scaleBy(x: 1.0, y: -1.0)
                $0.cgContext.draw(image, in: CGRect(origin: .zero, size: size))
//                $0.cgContext.restoreGState()
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
