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

    init(frame: CGRect = .zero, image: UIImage? = nil) {
        self.imageView = UIImageView(image: image)
        self.cropView = CropView(grid: Grid(numberOfRows: 3, numberOfColumns: 3))
        super.init(frame: frame)

        setup()

        addSubview(scrollView)
//        addSubview(effectsView)
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
//        setBlurIsVisible(true)
//        setCropViewGridIsVisible(false)
    }

    func set(_ photo: UIImage) {
        imageView.image = photo
        imageView.center = scrollView.center
        imageView.bounds.size = photo.size

        scrollView.centerContentView(imageView)
        scrollView.contentSize = photo.size
        updateScrollView()
    }

    func changeCropViewFrame(using corner: Corner, translation: CGPoint) {
        cropView.changeFrame(using: corner, translation: translation)
        saveScrollViewState()
        updateScrollViewInsets()
    }

    func fitCropView() {
        cropView.clipToBounds(allowedBounds, aspectScaled: true)
    }

    func setDimmingViewIsVisible(_ visible: Bool) {
//        updateMaskPath()
//        effectsView.setDimmingViewIsVisible(visible)
    }

    func setBlurIsVisible(_ visible: Bool) {
//        updateMaskPath()
//        effectsView.setBlurIsVisible(visible)
    }

    func setCropViewGridIsVisible(_ visible: Bool) {
        cropView.gridIsVisible = visible
    }

    func cropViewCorner(at point: CGPoint) -> Corner? {
        return cropView.cornerPosition(at: convert(point, to: cropView))
    }

    func saveScrollViewState() {
        scrollViewState = ScrollViewState(scale: scrollView.zoomScale,
                                          scrollFrame: .zero,
                                          visibleContentFrame: visibleRect)
    }

    func restoreScrollViewState() {
        let scale = min(cropView.frame.height / scrollViewState.visibleContentFrame.size.height,
                        cropView.frame.width / scrollViewState.visibleContentFrame.size.width)

        let rect = CGRect(origin: scrollViewState.visibleContentFrame.origin, size: CGSize(width: 5, height: 5))
            .applying(CGAffineTransform(translationX: cropView.frame.minX.distance(to: scrollView.frame.minX) * scale,
                                        y: cropView.frame.minY.distance(to: scrollView.frame.minY) * scale))

        scrollView.setZoomScale(scale, animated: false)
        scrollView.scrollRectToVisible(rect, animated: false)
        print(scrollView.bounds)

        let testview = UIView(frame: rect)
        testview.backgroundColor = .red

//        scrollView.contentOffset = CGPoint(x: testview.frame.origin.x, y: testview.frame.origin.y)

        let second = UIView(frame: CGRect(origin: scrollViewState.visibleContentFrame.origin, size: CGSize(width: 5, height: 5)))
        second.backgroundColor = .yellow

        imageView.addSubview(second)
        imageView.addSubview(testview)
    }

    private func updateScrollView(animated: Bool = false) {
        guard let image = photo else {
            return
        }

        scrollView.setZoomScale(cropView.frame.height / image.size.height, animated: animated)
        scrollView.scrollRectToVisible(scrollViewState.scrollFrame, animated: false)
    }

    private func makeConstraints() {
        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
//
//        effectsView.snp.makeConstraints { make in
//            make.edges.equalToSuperview()
//        }
    }

    private func updateScrollViewInsets() {
        let top = imageView.frame.minY.distance(to: cropView.frame.minY)
        let bottom = imageView.frame.maxY.distance(to: cropView.frame.maxY)
//        let left = imageView.frame.minX.distance(to: cropView.frame.minX)
//        let right = imageView.frame.maxX.distance(to: cropView.frame.maxX)
        print(scrollView.contentSize)
//        scrollView.contentSize = CGSize(width: scrollView.contentSize.width + top + bottom, height: scrollView.contentSize.height + left + right)
        print(scrollView.contentSize)

        let shouldChange = cropView.frame.isOutOfBounds(imageView.frame)

        if shouldChange {
            updateScrollView()
            scrollView.contentInset.top = top
            scrollView.contentInset.bottom = bottom
        }
    }

    private func layoutCropViewIfNeeded() {
        if cropView.frame == .zero {
            cropView.bounds.size = imageView.image?.size ?? .zero
            cropView.center = center
            cropView.allowedBounds = bounds.inset(by: UIEdgeInsets(repeated: 20))
            cropView.clipToBounds(bounds, aspectScaled: true)
            cropView.frame.fitInBounds(bounds)

            scrollView.centerContentView(imageView)
        }
    }

    private func updateMaskPath() {
        let path = CGMutablePath()
        path.addRect(bounds)
        path.addRect(cropView.frame)

        effectsView.setMaskPath(path)
    }

    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()

        scrollView.delegate = self
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.isScrollEnabled = true
        scrollView.minimumZoomScale = 0.1
        scrollView.maximumZoomScale = 5

        return scrollView
    }()

    private let imageView: UIImageView
    private let effectsView = EffectsView()
    private var cropView = CropView(frame: .zero)
    private var scrollViewState = ScrollViewState(scale: 1, scrollFrame: .zero, visibleContentFrame: .zero)
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
        saveScrollViewState()
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
        saveScrollViewState()
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
    }
}

private extension UIScrollView {
    func centerContentView(_ view: UIView, at point: CGPoint? = nil) {
        guard let index = subviews.firstIndex(of: view) else {
            return
        }

        let xOffset = max((bounds.width - contentSize.width) / 2, 0)
        let yOffset = max((bounds.height - contentSize.height) / 2, 0)

        subviews[index].center = CGPoint(x: contentSize.width / 2 + xOffset,
                                         y: contentSize.height / 2 + yOffset)
    }

    func scrollRect(_ rect: CGRect, toBeVisibleInView view: UIView) {
//            let diffrence = bo

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

extension CGPoint {
    func diffrence(with point: CGPoint) -> CGPoint {
        return CGPoint(x: x - point.x, y: y - point.y)
    }
}
