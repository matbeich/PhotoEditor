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

    var contentFrame: CGRect {
        return CGRect(x: -bounds.origin.x,
                      y: -bounds.origin.y,
                      width: contentSize.width,
                      height: contentSize.height)
    }

    func dragContentToCorrespondingEdge(of cropFrame: CGRect, using action: KeepInBoundsAction) {
        setContentOffset(action.contentOffsetInScrollView(self, forCropFrame: cropFrame, imageFrame: contentFrame), animated: false)
    }

    func centerWithView(_ view: UIView, animated: Bool = false) {
        let xOf = contentSize.width / 2 + view.center.x.distance(to: frame.minX)
        let yOf = contentSize.height / 2 + view.center.y.distance(to: frame.minY)

        setContentOffset(CGPoint(x: xOf, y: yOf), animated: animated)
    }
}
