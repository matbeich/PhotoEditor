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
        return convert(cropView.frame, to: imageView)
    }

    var photo: UIImage? {
        return imageView.image
    }

    var imageViewNotInCropView: Bool {
        let rect = CGRect(origin: CGPoint(x: -scrollView.contentOffset.x, y: -scrollView.contentOffset.y),
                          size: scrollView.contentSize)

        return !rect.contains(cropView.frame)
    }

    init(frame: CGRect = .zero, image: UIImage? = nil) {
        self.imageView = UIImageView(image: image)
        self.scrollView = UIScrollView(frame: frame)
        self.cropView = CropView(grid: Grid(numberOfRows: 3, numberOfColumns: 3))

        super.init(frame: frame)

        setup()
        setupScrollView()
        addSubview(scrollView)
        addSubview(effectsView)
        addSubview(cropView)

        makeConstraints()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("Not implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        layoutCropViewIfNeeded()

        scrollView.frame = bounds
        scrollView.centerWithView(cropView)
        scrollView.setMinimumZoomScaleToFit(cropView, animated: false)
        scrollView.setZoomScale(scrollView.minimumZoomScale, animated: false)

        updateMaskPath()
    }

    private func setup() {
        setBlurIsVisible(true)
        setCropViewGridIsVisible(false)
    }

    func set(_ photo: UIImage) {
        imageView = UIImageView(image: photo)
    }

    func changeCropViewFrame(using corner: Corner, translation: CGPoint) {
        cropView.changeFrame(using: corner, translation: translation)
    }

    func fitCropView() {
        cropView.clipToBounds(allowedBounds, aspectScaled: true)
    }

    func setDimmingViewIsVisible(_ visible: Bool) {
        updateMaskPath()
        effectsView.setDimmingViewIsVisible(visible)
    }

    func setBlurIsVisible(_ visible: Bool) {
        updateMaskPath()
        effectsView.setBlurIsVisible(visible)
    }

    func setCropViewGridIsVisible(_ visible: Bool) {
        cropView.gridIsVisible = visible
    }

    func cropViewCorner(at point: CGPoint) -> Corner? {
        return cropView.cornerPosition(at: convert(point, to: cropView))
    }

    func saveScrollViewState() {
        scrollViewState = ScrollViewState(scale: scrollView.zoomScale,
                                          scrollFrame: CGRect(origin: scrollView.contentOffset, size: .zero),
                                          visibleContentFrame: visibleRect)
    }

    func restoreScrollViewState() {
        let scale = min(cropView.frame.height / scrollViewState.visibleContentFrame.size.height,
                        cropView.frame.width / scrollViewState.visibleContentFrame.size.width)

        let cropViewOffset = CGPoint(x: cropView.frame.origin.x.distance(to: scrollView.frame.origin.x),
                                     y: cropView.frame.origin.y.distance(to: scrollView.frame.origin.y))

        let offset = scrollViewState.visibleContentFrame.origin
            .applying(CGAffineTransform(scaleX: scale, y: scale))
            .applying(CGAffineTransform(translationX: cropViewOffset.x, y: cropViewOffset.y))

        scrollView.setMinimumZoomScaleToFit(cropView, animated: false)
        scrollView.setZoomScale(scale, animated: false)
        scrollView.setContentOffset(offset, animated: false)
    }

    private func updateInsets() {
        let top = imageView.frame.minY.distance(to: cropView.frame.minY)
        let bottom = imageView.frame.maxY.distance(to: cropView.frame.maxY)
        let left = imageView.frame.minX.distance(to: cropView.frame.minX)
        let right = imageView.frame.maxX.distance(to: cropView.frame.maxX)

        scrollView.contentInset = UIEdgeInsets(top: top, left: left, bottom: bottom, right: right)

        print(scrollView.contentInset)
    }

    private func makeConstraints() {
        effectsView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    private func layoutCropViewIfNeeded() {
        if cropView.frame.isEmpty {
            cropView.bounds.size = imageView.image?.size ?? .zero
            cropView.center = center
            cropView.allowedBounds = bounds.inset(by: UIEdgeInsets(repeated: 20))
            cropView.clipToBounds(allowedBounds, aspectScaled: true)
        }
    }

    private func setupScrollView() {
        guard let image = imageView.image else {
            return
        }

        scrollView.removeFromSuperview()

        scrollView = UIScrollView(frame: bounds)
        scrollView.contentSize = image.size
        scrollView.delegate = self
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.isScrollEnabled = true
        scrollView.maximumZoomScale = 5
        scrollView.setMinimumZoomScaleToFit(cropView, animated: false)
        scrollView.zoomScale = scrollView.minimumZoomScale
        scrollView.contentInsetAdjustmentBehavior = .never
        scrollView.addSubview(imageView)

        insertSubview(scrollView, belowSubview: effectsView)
    }

    private func updateMaskPath() {
        let path = CGMutablePath()
        path.addRect(bounds)
        path.addRect(cropView.frame)

        effectsView.setMaskPath(path)
    }

    private var imageView: UIImageView {
        didSet {
            setupScrollView()
        }
    }

    private var scrollView: UIScrollView
    private let effectsView = EffectsView()
    private var cropView = CropView(frame: .zero)
    private var scrollViewState = ScrollViewState(scale: 1, scrollFrame: .zero, visibleContentFrame: .zero)
}

extension PhotoEditsView: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }

    func scrollViewWillBeginZooming(_ scrollView: UIScrollView, with view: UIView?) {
        updateInsets()
        setBlurIsVisible(false)
        setDimmingViewIsVisible(true)
    }

    func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        setDimmingViewIsVisible(false)
        setBlurIsVisible(true)
    }

    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        scrollView.centerWithView(cropView)

        if imageViewNotInCropView {
        }
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
}

private extension UIScrollView {
    func centerWithView(_ view: UIView) {
        let xOf = contentSize.width / 2 + view.center.x.distance(to: frame.minX)
        let yOf = contentSize.height / 2 + view.center.y.distance(to: frame.minY)

        setContentOffset(CGPoint(x: xOf, y: yOf), animated: false)
    }

    func setMinimumZoomScaleToFit(_ view: UIView, animated: Bool) {
        guard
            let imageView = subviews.first as? UIImageView,
            let image = imageView.image
        else {
            return
        }

        let scale = max(view.frame.height / image.size.height, view.frame.width / image.size.width)
        minimumZoomScale = scale
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
