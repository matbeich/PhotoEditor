//
// Copyright © 2018 Dimasno1. All rights reserved. Product:PhotoEditor
//

import Foundation

public struct Edits: Codable {
    var imageRotationAngle: CGFloat
    var relativeCutFrame: CGRect
    var filterName: String?

    public mutating func reset() {
        imageRotationAngle = 0
        relativeCutFrame = .zero
        filterName = nil
    }
}

extension Edits {
    static var initial: Edits {
        return Edits(imageRotationAngle: 0, relativeCutFrame: .zero, filterName: nil)
    }
}
