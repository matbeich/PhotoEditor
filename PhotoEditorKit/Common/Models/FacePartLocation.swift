//
// Copyright © 2018 Dimasno1. All rights reserved. Product:PhotoEditor
//

import Foundation
import Vision


public struct FacePartLocation {
    public let facePart: FacePart
    public let locations: [VNFaceLandmarkRegion2D]
}

public enum FacePart {
    case eyes
    case eyebrows
    case pupils
    case lips
    case nose
    case contour
    case all

    func landmarkRegionsFor(observation: VNFaceObservation) -> [VNFaceLandmarkRegion2D] {
        switch self {
        case .all:
            return [observation.landmarks?.allPoints] as? [VNFaceLandmarkRegion2D] ?? []

        case .contour:
            return [observation.landmarks?.faceContour] as? [VNFaceLandmarkRegion2D] ?? []

        case .eyes:
            return [observation.landmarks?.leftEye, observation.landmarks?.rightEye] as? [VNFaceLandmarkRegion2D] ?? []

        case .eyebrows:
            return [observation.landmarks?.leftEyebrow, observation.landmarks?.rightEyebrow] as? [VNFaceLandmarkRegion2D] ?? []

        case .pupils:
            return [observation.landmarks?.leftPupil, observation.landmarks?.rightPupil] as? [VNFaceLandmarkRegion2D] ?? []

        case .nose:
            return [observation.landmarks?.nose, observation.landmarks?.noseCrest] as? [VNFaceLandmarkRegion2D] ?? []

        case .lips:
            return [observation.landmarks?.innerLips, observation.landmarks?.outerLips] as? [VNFaceLandmarkRegion2D] ?? []
        }
    }
}
