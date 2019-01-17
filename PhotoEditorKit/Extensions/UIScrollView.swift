//
// Copyright © 2018 Dimasno1. All rights reserved. Product:PhotoEditor
//

import UIKit

public extension UIScrollView {
    var contentPositionInCenter: CGPoint {
        let x = ((bounds.width / 2) + contentOffset.x) / zoomScale
        let y = ((bounds.height / 2) + contentOffset.y) / zoomScale

        return CGPoint(x: x, y: y)
    }
}
