//
// Copyright © 2018 Dimasno1. All rights reserved. Product:PhotoEditor
//

import Foundation
import CoreImage

public enum AppFilter: String, CaseIterable {
    public typealias Specs = (name: String, parameters: [String: Any])

    case original
    case cold
    case light
    case warm
    case blackAndWhite
    case posterized
    case swampy
    case mars

    var description: String {
        return self.rawValue.camelCaseToWords()
    }

    var specs: Specs {
        switch self {
        case .original:
            return (Names.colorPolynomial, [:])

        case .cold:
            return (Names.temperatureAndTint, [ParametersKey.inputTargetNeutral: CIVector(x: 10100, y: 0)])

        case .light:
            let minComp = CIVector(repeating: 0.1, count: 4)
            let maxComp = CIVector(repeating: 0.9, count: 4)

            return (Names.colorClamp, [ParametersKey.minComponents: minComp,
                                       ParametersKey.maxComponents: maxComp])

        case .warm:
            return (Names.temperatureAndTint, [ParametersKey.inputTargetNeutral: CIVector(x: 3500, y: 0)])

        case .blackAndWhite:
            return (Names.effectNoir, [:])

        case .posterized:
            return (Names.colorPosterize, [ParametersKey.inputLevels: 4.5])

        case .swampy:
            return (Names.hueAdjust, [ParametersKey.inputAngle: 0.5])

        case .mars:
            return (Names.hueAdjust, [ParametersKey.inputAngle: -0.4])
        }
    }
}

extension AppFilter {
    enum Names {
        static let colorClamp = "CIColorClamp"
        static let temperatureAndTint = "CITemperatureAndTint"
        static let hueAdjust = "CIHueAdjust"
        static let effectNoir = "CIPhotoEffectNoir"
        static let edgeWork = "CIEdgeWork"
        static let lineOverlay = "CILineOverlay"
        static let colorInvert = "CIColorInvert"
        static let colorPosterize = "CIColorPosterize"
        static let colorPolynomial = "CIColorPolynomial"
    }

    enum ParametersKey: Hashable {
        static let minComponents = "inputMinComponents"
        static let maxComponents = "inputMaxComponents"
        static let inputRadius = "inputRadius"
        static let inputAngle = "inputAngle"
        static let inputLevels = "inputLevels"
        static let inputNoiseLevel = "inputNRNoiseLevel"
        static let inputNeutral = "inputNeutral"
        static let inputTargetNeutral = "inputTargetNeutral"
    }
}

private extension CIVector {
    convenience init(repeating value: CGFloat, count: Int) {
        let pointer: UnsafeMutableRawPointer = calloc(count, MemoryLayout<CGFloat>.size)
        pointer.initializeMemory(as: CGFloat.self, repeating: value, count: count)
        
        let unsafePointer = UnsafePointer<CGFloat>(OpaquePointer(pointer))
        
        self.init(values: unsafePointer, count: count)
        pointer.deallocate()
    }
}
