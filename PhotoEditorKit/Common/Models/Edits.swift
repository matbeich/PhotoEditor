//
// Copyright © 2018 Dimasno1. All rights reserved. Product:PhotoEditor
//

import Foundation

public struct Edits: Codable {
    public var imageRotationAngle: CGFloat?
    public var relativeCutFrame: CGRect?
    public var filterName: String?

    public init(angle: CGFloat? = nil, relativeCutFrame: CGRect? = nil, filterName: String? = nil) {
        self.imageRotationAngle = angle
        self.relativeCutFrame = relativeCutFrame
        self.filterName = filterName
    }

    public mutating func reset() {
        imageRotationAngle = nil
        relativeCutFrame = nil
        filterName = nil
    }
}

extension Edits {
    static var initial: Edits {
        return Edits()
    }
}
