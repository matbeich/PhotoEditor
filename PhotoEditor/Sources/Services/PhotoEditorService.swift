//
// Copyright © 2018 Dimasno1. All rights reserved. Product:PhotoEditor
//

import Accelerate
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

extension UIImage.Orientation {
    var description: String {
        switch self {
        case .down: return "DOWN"
        case .downMirrored: return "DOWN MIRRORED"
        case .left: return "LEFT"
        case .leftMirrored: return "LEFTY MIRRORED"
        case .right: return "RIGHT"
        case .rightMirrored: return "RIGHT MIRRORED"
        case .up: return "UP"
        case .upMirrored: return "UP MIRRORED"
        }
    }
}

extension UIImage {
    func cropedZone(_ zone: CGRect) -> UIImage? {
        let fixed = self.fixOrientation()
        guard let cutImageRef = fixed?.cgImage?.cropping(to: zone) else {
            return nil
        }

        return UIImage(cgImage: cutImageRef)
    }
}

extension UIImage {
    func fixOrientation() -> UIImage? {
        guard
            let cg = cgImage,
            let colorSpace = cg.colorSpace,
            let ctx = CGContext(data: nil,
                                width: Int(size.width),
                                height: Int(size.height),
                                bitsPerComponent: cg.bitsPerComponent,
                                bytesPerRow: cg.bytesPerRow,
                                space: colorSpace,
                                bitmapInfo: cg.bitmapInfo.rawValue)
        else {
            return nil
        }

        let shouldFlip = imageOrientation == .left || imageOrientation == .leftMirrored || imageOrientation == .right || imageOrientation == .rightMirrored
        let imgSize: CGSize = shouldFlip ? CGSize(width: size.height, height: size.width) : size

        ctx.saveGState()
        ctx.flip(for: imageOrientation, withSize: imgSize)
        ctx.draw(cg, in: CGRect(origin: .zero, size: imgSize))
        ctx.restoreGState()

        guard let img = ctx.makeImage() else {
            return nil
        }

        return UIImage(cgImage: img)
    }
}

extension CGContext {
    func flip(for imageOrientation: UIImage.Orientation, withSize size: CGSize) {
        var degrees: CGFloat = 90
        var translateValues: (x: CGFloat, y: CGFloat) = (x: 0, y: 0)
        var scaleValues: (x: CGFloat, y: CGFloat) = (x: 1.0, y: 1.0)

        switch imageOrientation {
        case .up:
            degrees = 0
        case .down:
            translateValues = (x: size.width, y: size.height)
            degrees = 180
        case .left:
            translateValues = (x: size.height, y: 0)
        case .right:
            translateValues = (x: 0, y: size.width)
            degrees = -90
        case .leftMirrored:
            scaleValues = (x: -1.0, y: 1.0)
            degrees = -90
        case .rightMirrored:
            scaleValues = (x: -1.0, y: 1.0)
            translateValues = (x: size.width + size.height, y: 0)
        case .downMirrored:
            scaleValues = (x: 1.0, y: -1.0)
            translateValues = (x: 0.0, y: size.height)
            degrees = 0
        case .upMirrored:
            scaleValues = (x: -1.0, y: 1.0)
            translateValues = (x: size.width, y: 0)
            degrees = 0
        }

        let radians = 2 * CGFloat.pi * (degrees / 360)

        scaleBy(x: scaleValues.x, y: scaleValues.y)
        translateBy(x: translateValues.x, y: translateValues.y)
        rotate(by: radians)
    }
}

extension UIImage {
    func resizeVI(size: CGSize) -> UIImage? {
        guard let cgImage = self.cgImage else {
            return nil
        }

        var sourceBuffer = vImage_Buffer()
        var format = vImage_CGImageFormat(bitsPerComponent: 8, bitsPerPixel: 32, colorSpace: nil,
                                          bitmapInfo: CGBitmapInfo(rawValue: CGImageAlphaInfo.first.rawValue),
                                          version: 0, decode: nil, renderingIntent: CGColorRenderingIntent.defaultIntent)

        defer { sourceBuffer.data.deallocate() }

        var error = vImageBuffer_InitWithCGImage(&sourceBuffer, &format, nil, cgImage, numericCast(kvImageNoFlags))
        guard error == kvImageNoError else { return nil }

        let scale = self.scale
        let destWidth = Int(size.width)
        let destHeight = Int(size.height)
        let bytesPerPixel = cgImage.bitsPerPixel / 8
        let destBytesPerRow = destWidth * bytesPerPixel
        let destData = UnsafeMutablePointer<UInt8>.allocate(capacity: destHeight * destBytesPerRow)

        defer { destData.deallocate() }

        var destBuffer = vImage_Buffer(data: destData, height: vImagePixelCount(destHeight), width: vImagePixelCount(destWidth), rowBytes: destBytesPerRow)

        // scale the image
        error = vImageScale_ARGB8888(&sourceBuffer, &destBuffer, nil, numericCast(kvImageHighQualityResampling))
        guard error == kvImageNoError else { return nil }

        // create a CGImage from vImage_Buffer
        let destCGImage = vImageCreateCGImageFromBuffer(&destBuffer, &format, nil, nil, numericCast(kvImageNoFlags), &error)?.takeRetainedValue()
        guard error == kvImageNoError else { return nil }

        // create a UIImage
        return destCGImage.flatMap { UIImage(cgImage: $0, scale: scale, orientation: self.imageOrientation) }
    }
}
