//
// Copyright © 2018 Dimasno1. All rights reserved. Product:PhotoEditor
//

import Foundation
import Vision

public protocol Image {
    var id: String { get }
}

public typealias FaceDetectionCallback = (VNRequest, Error?) -> Void

public final class FaceDetector {
    public init() {}

    public func addImage(_ image: Image) {
        var request: VNImageRequestHandler?
        let orientation = (image as? UIImage)?.cgOrientation ?? .up

        switch image {
        case let uiImg as UIImage:
            guard let underlyingCgImg = uiImg.cgImage else {
                assertionFailure("No underlying CGImage in this UIImage")
                return
            }

            request = VNImageRequestHandler(cgImage: underlyingCgImg, orientation: orientation, options: [:])

        case let cgImg as CGImage:
            request = VNImageRequestHandler(cgImage: cgImg, orientation: orientation, options: [:])

        case let ciImg as CIImage:
            request = VNImageRequestHandler(ciImage: ciImg, orientation: orientation, options: [:])

        case let imgData as Data:
            request = VNImageRequestHandler(data: imgData, orientation: orientation, options: [:])

        default:
            break
        }

        guard let requestHandler = request else {
            assertionFailure("Request is empty")
            return
        }

        requestHandlers.updateValue(requestHandler, forKey: image.id)
    }

    public func detectFacesOnImage(_ image: Image, callback: @escaping FaceDetectionCallback) {
        let faceRequest = VNDetectFaceLandmarksRequest(completionHandler: callback)

        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            do {
                try self?.requestHandlers[image.id]?.perform([faceRequest])
            } catch let error as NSError {
                print("Failed to perform image request: \(error)")
                return
            }
        }
    }

    private var requestHandlers = [String: VNImageRequestHandler]()
}

extension CGImage: Image {
    public var id: String {
        return String(describing: self.hashValue)
    }
}

extension CIImage: Image {
    public var id: String {
        return String(describing: self.hashValue)
    }
}

extension Data: Image {
    public var id: String {
        return String(describing: self.hashValue)
    }
}

extension UIImage: Image {
    public var id: String {
        return String(describing: self.hashValue)
    }

    var cgOrientation: CGImagePropertyOrientation {
        switch imageOrientation {
        case .up:
            return .up
        case .down:
            return .down
        case .left:
            return .left
        case .right:
            return .right
        case .downMirrored:
            return .downMirrored
        case .upMirrored:
            return .upMirrored
        case .leftMirrored:
            return .leftMirrored
        case .rightMirrored:
            return .rightMirrored
        }
    }
}
