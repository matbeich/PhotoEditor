//
// Copyright © 2018 Dimasno1. All rights reserved. Product:PhotoEditor
//

import UIKit

protocol PhotoEditorServiceType {
    func cropeZone(_ zone: CGRect, of image: UIImage) -> UIImage?
    func rotateImage(_ image: UIImage, byDegrees degrees: CGFloat, clockwise: Bool) -> UIImage?
    func filterImage(_ image: UIImage, withFilterNamed name: String) -> UIImage?
    func changeColor(of image: UIImage, withValue value: CGFloat) -> UIImage?
    func changedBrightness(of image: UIImage, withValue value: CGFloat) -> UIImage?
}

final class PhotoEditorService {
    init(options: [CIContextOption: Any]? = nil) {
        self.context = CIContext(options: options)
    }

    func cropeZone(_ zone: CGRect, of image: UIImage) -> UIImage? {
        return nil
    }

    func rotateImage(_ image: UIImage, byDegrees degrees: CGFloat, clockwise: Bool) -> UIImage? {
        return nil
    }

    func filterImage(_ image: UIImage, withFilterNamed name: String) -> UIImage? {
        guard let filter = CIFilter(name: name), let ciImage = CIImage(image: image) else {
            return nil
        }

        filter.setValue(ciImage, forKey: kCIInputImageKey)

        guard let outputImg = filter.outputImage, let cgResult = context.createCGImage(outputImg, from: ciImage.extent) else {
            return nil
        }

        return UIImage(cgImage: cgResult)
    }

    func changeColor(of image: UIImage, withValue value: CGFloat) -> UIImage? {
        return nil
    }

    func changedBrightness(of image: UIImage, withValue value: CGFloat) -> UIImage? {
        return nil
    }

    func asyncApplyFilterNamed(_ name: String, to image: UIImage, with callback: @escaping (UIImage?) -> Void) {
        DispatchQueue.global().async { [weak self] in
            let img = self?.filterImage(image, withFilterNamed: name)

            DispatchQueue.main.async {
                callback(img)
            }
        }
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
