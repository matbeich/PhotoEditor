//
// Copyright © 2018 Dimasno1. All rights reserved. Product:PhotoEditor
//

import UIKit

protocol PhotoEditorServiceType {
    func cropedFrom(_ image: UIImage, rect: CGRect) -> UIImage?
    func rotate()
    func applyFilter() -> UIImage
    func changeColor()
    func changeBrightness()
}

final class PhotoEditorService: PhotoEditorServiceType {
    init(options: [CIContextOption : Any]? = nil) {
        self.context = CIContext(options: options)
    }

    func cropImage(_ image: UIImage, rect: CGRect) -> UIImage? {
        return image.cropedZone(rect)
    }

    func rotate() {}

    func applyFilter() -> UIImage {
        let image = UIImage(named: "test.png")!

        let ciImage = CIImage(image: image)!
        let filter = CIFilter(name: "CISepiaTone")!
        filter.setIntensity(3)

        return UIImage()
    }

    func changeColor() {}
    func changeBrightness() {}

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

extension CIFilter {
    func setIntensity(_ intensity: CGFloat) {
        setValue(intensity, forKey: kCIInputIntensityKey)
    }

    func apply(to image: CIImage, intensity: CGFloat) {
        setValue(image, forKey: kCIInputImageKey)

    }
}
