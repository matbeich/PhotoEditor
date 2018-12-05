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

    // FIXME: Add logic

    public func changeColor(of image: UIImage, withValue value: CGFloat) -> UIImage? {
        return nil
    }

    // FIXME: Add logic

    public func changedBrightness(of image: UIImage, withValue value: CGFloat) -> UIImage? {
        return nil
    }

    // FIXME: Add logic

    public func rotateImage(_ image: UIImage, byDegrees degrees: CGFloat, clockwise: Bool) -> UIImage? {
        return nil
    }

    private let context: CIContext
}
