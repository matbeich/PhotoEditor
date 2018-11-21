//
// Copyright © 2018 Dimasno1. All rights reserved. Product: PhotoEditor
//

import SnapKit
import UIKit
import Utils

class CropView: UIView {
    override var frame: CGRect {
        didSet {
            setNeedsDisplay()
        }
    }

    var allowedBounds: CGRect {
        didSet {
            guard min(allowedBounds.width, allowedBounds.height) >= Config.cropViewMinDimension else {
                return
            }
//
//            clipToBounds(allowedBounds, aspectScaled: false)
//            frame.fitInBounds(allowedBounds)
        }
    }

    var gridIsVisible: Bool = true {
        didSet {
            setNeedsDisplay()
        }
    }

    init(frame: CGRect = .zero, grid: Grid? = nil) {
        self.grid = grid
        self.allowedBounds = frame
        super.init(frame: frame)

        backgroundColor = .clear
        layer.borderWidth = 1
        layer.borderColor = UIColor.white.cgColor

        setup()
        makeConstraints()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("Not implemented")
    }

    override func draw(_ rect: CGRect) {
        guard let ctx = UIGraphicsGetCurrentContext() else {
            return
        }

        ctx.setStrokeColor(UIColor.lightGray.cgColor)
        ctx.setLineWidth(0.3)

        if let grid = grid, gridIsVisible {
            grid.draw(with: ctx, in: rect)
        } else {
            ctx.stroke(rect)
        }

        super.draw(rect)
    }

    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        return cornerPosition(at: point) != nil
    }

    func cornerPosition(at point: CGPoint) -> Corner? {
        let sortedCorners = cornerViews.sorted { $0.center.distance(to: point) < $1.center.distance(to: point) }

        return sortedCorners.first(where: { $0.frame.center.distance(to: point) < CGFloat(50.0) })?.corner
    }

    func changeFrame(using corner: Corner, translation: CGPoint) {
        let newFrame = frame(for: translation, using: corner)

        let canChangeWidth = newFrame.width > Config.cropViewMinDimension
            && (newFrame.maxX <= allowedBounds.maxX)
            && (newFrame.minX >= allowedBounds.minX)

        let canChangeHeight = newFrame.height > Config.cropViewMinDimension
            && (newFrame.maxY <= allowedBounds.maxY)
            && (newFrame.minY >= allowedBounds.minY)

        switch (canChangeHeight, canChangeWidth) {
        case (true, true):
            frame = newFrame

        case (true, false):
            frame = CGRect(x: frame.origin.x, y: newFrame.origin.y,
                           width: frame.width, height: newFrame.height)

        case (false, true):
            frame = CGRect(x: newFrame.origin.x, y: frame.origin.y,
                           width: newFrame.width, height: frame.height)

        default: break
        }
    }

    private func frame(for translation: CGPoint, using corner: Corner) -> CGRect {
        switch corner {
        case .bottomLeft:
            return CGRect(x: frame.origin.x + translation.x,
                          y: frame.origin.y,
                          width: frame.width - translation.x,
                          height: frame.height + translation.y)
        case .bottomRight:
            return CGRect(x: frame.origin.x,
                          y: frame.origin.y,
                          width: frame.width + translation.x,
                          height: frame.height + translation.y)
        case .topLeft:
            return CGRect(x: frame.origin.x + translation.x,
                          y: frame.origin.y + translation.y,
                          width: frame.width - translation.x,
                          height: frame.height - translation.y)
        case .topRight:
            return CGRect(x: frame.origin.x,
                          y: frame.origin.y + translation.y,
                          width: frame.width + translation.x,
                          height: frame.height - translation.y)
        }
    }

    private func setup() {
        cornerViews.forEach { addSubview($0) }
    }

    private func makeConstraints() {
        cornerViews.forEach { cornerView in
            cornerView.snp.makeConstraints { make in
                make.height.width.equalTo(20)

                switch cornerView.corner {
                case .bottomLeft:
                    make.bottom.left.equalToSuperview()
                case .bottomRight:
                    make.bottom.right.equalToSuperview()
                case .topLeft:
                    make.top.left.equalToSuperview()
                case .topRight:
                    make.top.right.equalToSuperview()
                }
            }
        }
    }

    private let cornerViews = [
        CornerView(corner: .topLeft),
        CornerView(corner: .topRight),
        CornerView(corner: .bottomLeft),
        CornerView(corner: .bottomRight)
    ]

    private var grid: Grid?
}

extension CGRect {
    mutating func fitInBounds(_ bounds: CGRect) {
        if minX < bounds.minX { origin.x = bounds.minX }
        if minY < bounds.minY { origin.y = bounds.minY }
        if maxX > bounds.maxX { size.width = width - (maxX - bounds.maxX) }
        if maxY > bounds.maxY { size.height = height - (maxY - bounds.maxY) }
    }
}

extension UIView {
    func clipToBounds(_ bounds: CGRect, aspectScaled: Bool = false) {
        let scale = min(bounds.size.height / frame.size.height, bounds.size.width / frame.size.width)

        self.bounds.size = aspectScaled ? frame.size.applying(CGAffineTransform(scaleX: scale, y: scale)) : bounds.size
        self.center = bounds.center
    }
}
