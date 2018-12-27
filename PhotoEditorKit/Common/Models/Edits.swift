//
// Copyright © 2018 Dimasno1. All rights reserved. Product:PhotoEditor
//

import Foundation

public struct Edits: Codable {
    var rotationAngle: CGFloat
    var relativeCropRectangle: CGRect?
    var filterName: String?
}
