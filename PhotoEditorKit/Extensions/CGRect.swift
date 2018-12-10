//
// Copyright © 2018 Dimasno1. All rights reserved. Product:PhotoEditor
//

import CoreGraphics

public extension CGRect {
    public func absolute(in bounds: CGRect) -> CGRect {
        return CGRect(x: bounds.size.width * origin.x,
                      y: bounds.size.height * origin.y,
                      width: bounds.size.width * width,
                      height: bounds.size.height * height)
    }
}
