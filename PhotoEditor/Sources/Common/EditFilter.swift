//
// Copyright © 2018 Dimasno1. All rights reserved. Product:PhotoEditor
//

import CoreImage

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
