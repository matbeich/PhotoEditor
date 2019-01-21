//
// Copyright © 2018 Dimasno1. All rights reserved. Product:PhotoEditor
//

import Foundation

public struct Edits: Codable {
    public var imageRotationAngle: CGFloat
    public var relativeCutFrame: CGRect
    public var filterName: String?

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
