//
// Copyright © 2018 Dimasno1. All rights reserved. Product: PhotoEditor
//

import SnapKit
import UIKit

class PhotoEditsView: UIView {
    var allowedBounds: CGRect {
        return cropView.allowedBounds
    }

    var visibleRect: CGRect {
        return convert(scrollView.frame, to: imageView)
    }

    var scrollViewState = ScrollViewState(scale: 1, visibleFrame: .zero)

    var image: UIImage? {
        return imageView.image
    }

    init(frame: CGRect = .zero, image: UIImage? = nil) {
        self.imageView = UIImageView(image: image)
        self.cropView = CropView(grid: Grid(numberOfRows: 3, numberOfColumns: 3))
        super.init(frame: frame)

        setup()
        addSubview(scrollView)
        addSubview(maskingViewsContainer)
        addSubview(cropView)
        scrollView.addSubview(imageView)
        makeConstraints()
    }

    required init?(coder aDecoder: NSCoder) {
        self.imageView = UIImageView()
        super.init(coder: aDecoder)
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        layoutCropViewIfNeeded()
        updateMaskPath()
    }

    private func setup() {
        setBlurIsVisible(true)
        setCropViewGridIsVisible(false)

        scrollView.delegate = self
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.isScrollEnabled = true
        scrollView.minimumZoomScale = 0.1
        scrollView.maximumZoomScale = 1
    }

    private func updateScrollViewInsets() {
        let top = imageView.frame.minY.distance(to: cropView.frame.minY)

        guard let img = image else {
            return
        }

        let shouldChange = cropView.frame.isOutOfBounds(imageView.frame)

        if shouldChange {
            let zoomScale = cropView.frame.height / img.size.height
            scrollView.zoomScale = zoomScale
            scrollView.contentOffset = CGPoint(x: 0, y: -top)
        }
    }

    func changeCropViewFrame(using corner: Corner, translation: CGPoint) {
        cropView.changeFrame(using: corner, translation: translation)
        updateScrollViewInsets()
    }

    func fitCropView() {
        cropView.clipToBounds(bounds, aspectScaled: true)
        cropView.frame.fitInBounds(allowedBounds)
    }

    func setDimmingViewIsVisible(_ visible: Bool) {
        updateMaskPath()

        if dimmingView.isHidden == visible {
            dimmingView.isHidden = !visible
        }
    }

    func setBlurIsVisible(_ visible: Bool) {
        updateMaskPath()

        if blurView.isHidden == visible {
            blurView.isHidden = !visible
        }
    }

    func setCropViewGridIsVisible(_ visible: Bool) {
        cropView.gridIsVisible = visible
    }

    func set(_ photo: UIImage) {
        imageView.image = photo
        imageView.center = scrollView.center
        imageView.bounds.size = photo.size

        scrollView.centerContentView(imageView)
        scrollView.contentSize = photo.size
    }

    func cropViewCorner(at point: CGPoint) -> Corner? {
        return cropView.cornerPosition(at: convert(point, to: cropView))
    }

    private func makeConstraints() {
        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        maskingViewsContainer.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        blurView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        dimmingView.snp.makeConstraints { make in
            make.top.edges.equalToSuperview()
        }
    }

    private func layoutCropViewIfNeeded() {
        if cropView.frame == .zero {
            cropView.bounds.size = imageView.image?.size ?? .zero
            cropView.center = center
            cropView.allowedBounds = bounds.inset(by: UIEdgeInsets(repeated: 20))
            cropView.clipToBounds(bounds, aspectScaled: true)
            cropView.frame.fitInBounds(bounds)
        }
    }

    private func updateMaskPath() {
        let path = CGMutablePath()
        path.addRect(bounds)
        path.addRect(cropView.frame)

        maskLayer.path = path
    }

    private let maskLayer: CAShapeLayer = {
        let layer = CAShapeLayer()

        layer.fillColor = UIColor.white.cgColor
        layer.fillRule = .evenOdd

        return layer
    }()

    private lazy var maskingViewsContainer: UIView = {
        let container = UIView()

        container.addSubview(dimmingView)
        container.addSubview(blurView)
        container.layer.mask = maskLayer
        container.isUserInteractionEnabled = false

        return container
    }()

    private let dimmingView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        view.isHidden = true

        return view
    }()

    private let blurView: UIVisualEffectView = {
        let effect = UIBlurEffect(style: .dark)

        return UIVisualEffectView(effect: effect)
    }()

    private let imageView: UIImageView
    private let scrollView = UIScrollView()
    private var cropView = CropView(frame: .zero)
}

extension PhotoEditsView: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }

    func scrollViewWillBeginZooming(_ scrollView: UIScrollView, with view: UIView?) {
        setBlurIsVisible(false)
        setDimmingViewIsVisible(true)
    }

    func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        setDimmingViewIsVisible(false)
        setBlurIsVisible(true)
    }

    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        scrollView.centerContentView(imageView)
    }

    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        setCropViewGridIsVisible(true)
        setDimmingViewIsVisible(true)
        setBlurIsVisible(false)
    }

    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        setCropViewGridIsVisible(false)
        setDimmingViewIsVisible(false)
        setBlurIsVisible(true)
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
    }
}

extension UIScrollView {
    func centerContentView(_ view: UIView) {
        guard let index = subviews.firstIndex(of: view) else {
            return
        }

        let xOffset = max((bounds.width - contentSize.width) / 2, 0)
        let yOffset = max((bounds.height - contentSize.height) / 2, 0)

        subviews[index].center = CGPoint(x: contentSize.width / 2 + xOffset,
                                         y: contentSize.height / 2 + yOffset)
    }
}

extension CGRect {
    var area: CGFloat {
        return width * height
    }

    func isOutOfBounds(_ bounds: CGRect) -> Bool {
        return bounds.minX - minX > 1
            || bounds.maxX - maxX < -1
            || bounds.minY - minY > 1
            || bounds.maxY - maxY < -1
    }
}
