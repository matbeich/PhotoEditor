//
// Copyright © 2018 Dimasno1. All rights reserved. Product:PhotoEditor
//

import UIKit

protocol PhotoEditorServiceType {
    func cropImage(_ image: UIImage, rect: CGRect) -> UIImage?
    func rotate()
    func applyFilter()
    func changeColor()
    func changeBrightness()
}

final class PhotoEditorService: PhotoEditorServiceType {
    func cropImage(_ image: UIImage, rect: CGRect) -> UIImage? {
        return image.cropedZone(rect)
    }

    func rotate() {}
    func applyFilter() {}
    func changeColor() {}
    func changeBrightness() {}
}

extension UIImage {
    func cropedZone(_ zone: CGRect) -> UIImage? {
        guard let cutImageRef = cgImage?.cropping(to: zone) else {
            return nil
        }

        return UIImage(cgImage: cutImageRef)
    }
}
