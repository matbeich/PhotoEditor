//
// Copyright © 2018 Dimasno1. All rights reserved. Product:PhotoEditor
//

import UIKit

final class FilterMixer {
    private typealias Parameters = [String: Any]

    var filterNames: [String] {
        return Array(additionalFilters.keys)
    }

    func asyncApplyToImage(_ image: UIImage, callback: @escaping (UIImage?) -> Void) {
        DispatchQueue.global().async { [weak self] in
            let img = self?.applyToImage(image)

            DispatchQueue.main.async {
                callback(img)
            }
        }
    }

    func applyToImage(_ image: UIImage) -> UIImage? {
        let ciImage = CIImage(image: image)

        filter?.setValue(ciImage, forKey: kCIInputImageKey)

        guard
            let img = applyAdditionalFiltersToImage(image: filter?.outputImage),
            let cgResult = context.createCGImage(img, from: img.extent)
        else {
            return nil
        }

        return UIImage(cgImage: cgResult)
    }

    func addFilter(_ named: String, parameters: [String: Any] = [:]) {
        if filter == nil {
            filter = CIFilter(name: named, parameters: parameters)
        } else {
            additionalFilters[named] = filtered(parameters)
        }
    }

    func removeFiter(_ named: String) {
        additionalFilters.removeValue(forKey: named)
    }

    private func filtered(_ parameters: Parameters) -> Parameters {
        return parameters.filter { $0.key != kCIInputImageKey }
    }

    private func applyAdditionalFiltersToImage(image: CIImage?) -> CIImage? {
        var image: CIImage? = image
        additionalFilters.forEach { image = image?.applyingFilter($0, parameters: $1) }

        return image
    }

    private var filter: CIFilter?
    private let context = CIContext(options: nil)
    private var additionalFilters: [String: Parameters] = [:]
}
