//
// Copyright © 2018 Dimasno1. All rights reserved. Product:PhotoEditor
//

import UIKit


public enum KeepInBoundsAction {
    case dragUp
    case dragDown
    case dragLeft
    case dragRight
    case zoomFitWidth
    case zoomFitHeight
    case none

    init(cropFrame: CGRect, imageFrame: CGRect) {
        let fitHeight = cropFrame.height > imageFrame.height
        let fitWidth = cropFrame.width > imageFrame.width

        self = .none

        if fitHeight {
            self = .zoomFitHeight
        }

        if fitWidth {
            self = .zoomFitWidth
        }

        if (cropFrame.minY < imageFrame.minY) && !fitHeight {
            self = .dragUp
        }

        if (cropFrame.maxY > imageFrame.maxY) && !fitHeight {
            self = .dragDown
        }

        if (cropFrame.minX < imageFrame.minX) && !fitWidth {
            self = .dragLeft
        }

        if (cropFrame.maxX > imageFrame.maxX) && !fitWidth {
            self = .dragRight
        }
    }

    func contentOffsetInScrollView(_ scrollView: UIScrollView,forCropFrame frame: CGRect, imageFrame: CGRect) -> CGPoint {
        switch self {
        case .dragDown:
            return CGPoint(x: scrollView.contentOffset.x,
                           y: scrollView.contentOffset.y - (frame.maxY - imageFrame.maxY))
        case .dragUp:
            return CGPoint(x: scrollView.contentOffset.x,
                           y: scrollView.contentOffset.y - (frame.minY - imageFrame.minY))
        case .dragLeft:
            return CGPoint(x: scrollView.contentOffset.x - (frame.minX - imageFrame.minX),
                           y: scrollView.contentOffset.y)
        case .dragRight:
            return CGPoint(x: scrollView.contentOffset.x - (frame.maxX - imageFrame.maxX),
                           y: scrollView.contentOffset.y)
        case .zoomFitWidth:
            return CGPoint(x: -(frame.center.x - scrollView.contentSize.width / 2),
                           y: scrollView.contentOffset.y)
        case .zoomFitHeight:
            return CGPoint(x: scrollView.contentOffset.x,
                           y: -(frame.center.y - scrollView.contentSize.height / 2))
        case .none:
            return scrollView.contentOffset
        }
    }
}
