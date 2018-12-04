//
// Copyright © 2018 Dimasno1. All rights reserved. Product:PhotoEditor
//

import Foundation

public typealias Watermark = UIImage

public final class WatermarkRenderer {
    public var watermark: Watermark

    public init(watermark: Watermark) {
        self.watermark = watermark
    }

    public func renderWatermark(on image: UIImage, then callback: @escaping (UIImage?) -> Void) {
        DispatchQueue.global().async { [weak self] in
            let img = self?.renderWatermark(on: image)

            DispatchQueue.main.async {
                callback(img)
            }
        }
    }

    private func renderWatermark(on image: UIImage) -> UIImage? {
        guard let cgWatermark = watermark.cgImage else {
            return nil
        }
        let renderer = UIGraphicsImageRenderer(size: image.size)
        let scale = min(image.size.width, image.size.height) / max(watermark.size.width, watermark.size.height)

        let xOffset = (image.size.width - watermark.size.width) / 2
        let yOffset = (image.size.height - watermark.size.height) / 2
        let rect = CGRect(origin: CGPoint(x: xOffset * scale, y: yOffset * scale),
                          size: watermark.size.applying(CGAffineTransform(scaleX: scale, y: scale)))

        return renderer.image { ctx in
            ctx.cgContext.saveGState()
            defer { ctx.cgContext.restoreGState() }
            ctx.cgContext.rotate(by: -CGFloat.pi)
            ctx.cgContext.translateBy(x: 0, y: image.size.height / 2)
            ctx.cgContext.draw(cgWatermark, in: rect)
        }
    }
}
