//
// Copyright © 2018 Dimasno1. All rights reserved. Product:PhotoEditor
//

import Foundation

public typealias Watermark = UIImage
public typealias RendererCallback = (UIImage?) -> Void

public final class WatermarkRenderer {
    public var watermark: Watermark

    public init(watermark: Watermark) {
        self.watermark = watermark
    }

    public func asyncRenderWatermark(on image: UIImage, then callback: @escaping RendererCallback) {
        DispatchQueue.global().async { [weak self] in
            let img = self?.renderWatermark(on: image)

            DispatchQueue.main.async {
                callback(img)
            }
        }
    }

    public func renderWatermark(on image: UIImage) -> UIImage? {
        let renderer = UIGraphicsImageRenderer(size: image.size)

        guard let cgimage = image.cgImage, let cgWatermark = watermark.cgImage else {
            return nil
        }

        let frame = CGRect(origin: CGPoint(x: image.size.width - watermark.size.width, y: 0),
                           size: watermark.size)

        return renderer.image { ctx in
            ctx.cgContext.saveGState()
            ctx.cgContext.flip(for: .downMirrored, withSize: image.size)
            ctx.cgContext.draw(cgimage, in: CGRect(origin: .zero, size: image.size))
            ctx.cgContext.draw(cgWatermark, in: frame)
            ctx.cgContext.restoreGState()
        }
    }
}
