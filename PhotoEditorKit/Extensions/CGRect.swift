//
// Copyright © 2018 Dimasno1. All rights reserved. Product:PhotoEditor
//

import CoreGraphics

public extension CGRect {
    public func toAbsolute(with boundsSize: CGSize) -> CGRect {
        return CGRect(x: boundsSize.width * origin.x,
                      y: boundsSize.height * origin.y,
                      width: boundsSize.width * width,
                      height: boundsSize.height * height)
    }
}
