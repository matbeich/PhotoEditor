//
// Copyright © 2018 Dimasno1. All rights reserved. Product:PhotoEditor
//

import Foundation
import Vision

public protocol Image {
    var id: String { get }
}

public typealias FaceDetectionCallback = (VNRequest, Error?) -> Void
public typealias FacePartsDetectionCallback = ([FacePartLocation]) -> Void

public final class FaceDetector {

    public init() {}

    public func prepareForImage(_ image: Image) {
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

    public func detectPartsOfFace(_ parts: [FacePart], on image: UIImage, callback: @escaping FacePartsDetectionCallback) {
        let faceDetectionCallback: FaceDetectionCallback = { request, error in
            var callbackResults = [FacePartLocation]()

            guard error == nil else {
                callback(callbackResults)
                return
            }

            let results = request.results as? [VNFaceObservation]

            results?.forEach { faceObservation in
                parts.forEach {
                    callbackResults.append(FacePartLocation(facePart: $0, locations: $0.landmarkRegionsFor(observation: faceObservation)))
                }
            }

            callback(callbackResults)
        }

        detectFacesOnImage(image, callback: faceDetectionCallback)
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
