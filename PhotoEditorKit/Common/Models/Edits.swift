//
// Copyright © 2018 Dimasno1. All rights reserved. Product:PhotoEditor
//

import Foundation

public struct Edits: Codable {
    public var imageRotationAngle: CGFloat
    public var relativeCutFrame: CGRect?
    public var filter: AppFilter?

    public init(angle: CGFloat? = nil, relativeCutFrame: CGRect? = nil, filter: AppFilter? = nil) {
        self.imageRotationAngle = angle ?? 0
        self.relativeCutFrame = relativeCutFrame
        self.filter = filter
    }

    public mutating func reset() {
        imageRotationAngle = 0
        relativeCutFrame = nil
        filter = nil
    }
}

extension Edits {
    static var initial: Edits {
        return Edits()
    }
}
