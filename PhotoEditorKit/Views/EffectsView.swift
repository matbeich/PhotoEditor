//
// Copyright © 2018 Dimasno1. All rights reserved. Product:PhotoEditor
//

import SnapKit
import UIKit

final class EffectsView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)

        isUserInteractionEnabled = false
        layer.mask = maskLayer

        addSubview(dimmingView)
        addSubview(blurView)
        makeConstraints()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    func setDimmingViewIsVisible(_ visible: Bool) {
        if dimmingView.isHidden == visible {
            dimmingView.isHidden = !visible
        }
    }

    func setBlurIsVisible(_ visible: Bool) {
        if blurView.isHidden == visible {
            blurView.isHidden = !visible
        }
    }

    func setMaskPath(_ path: CGPath) {
        maskLayer.path = path
    }

    private func makeConstraints() {
        blurView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        dimmingView.snp.makeConstraints { make in
            make.top.edges.equalToSuperview()
        }
    }

    private let dimmingView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        view.isHidden = true

        return view
    }()

    private let maskLayer: CAShapeLayer = {
        let layer = CAShapeLayer()

        layer.fillColor = UIColor.white.cgColor
        layer.fillRule = .evenOdd

        return layer
    }()

    private let blurView: UIVisualEffectView = {
        let effect = UIBlurEffect(style: .dark)

        return UIVisualEffectView(effect: effect)
    }()
}
