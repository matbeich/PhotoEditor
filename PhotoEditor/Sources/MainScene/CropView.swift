//
// Copyright © 2018 Dimasno1. All rights reserved. Product: PhotoEditor
//

import SnapKit
import UIKit
import Utils

class CropView: UIView {
    var showGrid: Bool = true {
        didSet {
            setNeedsDisplay()
        }
    }

    init(frame: CGRect, grid: Grid?) {
        self.grid = grid
        super.init(frame: frame)

        backgroundColor = .clear
        layer.borderWidth = 1
        layer.borderColor = UIColor.white.cgColor

        setup()
        makeConstraints()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func draw(_ rect: CGRect) {
        super.draw(rect)

        guard let ctx = UIGraphicsGetCurrentContext() else {
            return
        }

        ctx.setStrokeColor(UIColor.lightGray.cgColor)
        ctx.setLineWidth(1)

        let rect = rect.inset(by: UIEdgeInsets(top: -4, left: -4, bottom: 4, right: 4))

        if let grid = grid, showGrid {
            grid.draw(with: ctx, in: rect)
        } else {
            ctx.stroke(rect)
        }
    }

    func cornerPosition(at point: CGPoint) -> Corner? {
        let sortedCorners = cornerViews.sorted { $0.center.distance(to: point) < $1.center.distance(to: point) }

        return sortedCorners.first(where: { $0.frame.center.distance(to: point) < CGFloat(30.0) })?.corner
    }

    func changeFrame(using corner: Corner, translation: CGPoint) {
        let newFrame = frame(for: translation, using: corner)

        let canChangeWidth = newFrame.width > minimuAlowedMagnitude
        let canChangeHeight = newFrame.height > minimuAlowedMagnitude

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
                make.height.equalToSuperview().multipliedBy(0.2)
                make.width.equalToSuperview().multipliedBy(0.2)

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
    private let minimuAlowedMagnitude: CGFloat = 100.0
}
