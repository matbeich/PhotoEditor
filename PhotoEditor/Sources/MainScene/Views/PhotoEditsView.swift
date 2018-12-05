//
// Copyright © 2018 Dimasno1. All rights reserved. Product: PhotoEditor
//

import PhotoEditorKit
import SnapKit
import UIKit

final class PhotoEditsView: UIView {
    var canCrop: Bool {
        return mode.state.showCrop
    }

    var photo: UIImage? {
        return imageView.image
    }

    var allowedBounds: CGRect {
        return cropView.allowedBounds
    }

    var visibleRect: CGRect {
        return convert(cropView.frame, to: imageView)
    }

    var mode: EditMode = .normal {
        didSet {
            applyMode()
        }
    }

    init(frame: CGRect = .zero, image: UIImage? = nil) {
        self.imageView = UIImageView(image: image)
        self.scrollView = UIScrollView(frame: frame)
        self.cropView = CropView(grid: Grid(numberOfRows: 3, numberOfColumns: 3))
        self.visibleContentFrame = .zero

        super.init(frame: frame)

        setupScrollView()
        addSubview(scrollView)
        addSubview(effectsView)
        addSubview(cropView)

        applyMode()
        makeConstraints()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("Not implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        layoutCropViewIfNeeded()
        layoutScrollViewIfNeeded()
        updateMaskPath()
    }

    func showMask() {
        setBlurIsVisible(false)
        setDimmingViewIsVisible(true)
        setCropViewIsVisible(true)
        setCropViewGridIsVisible(true)
    }

    func hideMask() {
        setBlurIsVisible(true)
        setDimmingViewIsVisible(false)
        setCropViewIsVisible(true)
        setCropViewGridIsVisible(false)
    }

    func set(_ photo: UIImage) {
        saveCropedRect()
        imageView = UIImageView(image: photo)
        setNeedsDisplay()
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

    func setCropViewIsVisible(_ visible: Bool) {
        cropView.isHidden = !visible
        cropView.isUserInteractionEnabled = visible
    }

    func saveCropedRect() {
        visibleContentFrame = visibleRect
    }

    func fitSavedRectToCropView() {
        let scale = min(cropView.frame.height / visibleContentFrame.size.height,
                        cropView.frame.width / visibleContentFrame.size.width)

        let cropViewOffset = CGPoint(x: cropView.frame.origin.x.distance(to: scrollView.frame.origin.x),
                                     y: cropView.frame.origin.y.distance(to: scrollView.frame.origin.y))

        let offset = visibleContentFrame.origin
            .applying(CGAffineTransform(scaleX: scale, y: scale))
            .applying(CGAffineTransform(translationX: cropViewOffset.x, y: cropViewOffset.y))

        scrollView.minimumZoomScale = fitScaleForImage(photo)
        scrollView.setZoomScale(scale, animated: false)
        scrollView.setContentOffset(offset, animated: false)
        scrollView.isUserInteractionEnabled = mode.state.canScroll

        updateInsets()
    }

    func changeCropViewFrame(using corner: Corner, translation: CGPoint) {
        cropView.changeFrame(using: corner, translation: translation)
    }

    private func updateInsets() {
        let top = imageView.frame.minY.distance(to: cropView.frame.minY)
        let bottom = imageView.frame.maxY.distance(to: cropView.frame.maxY)
        let left = imageView.frame.minX.distance(to: cropView.frame.minX)
        let right = imageView.frame.maxX.distance(to: cropView.frame.maxX)

        let vertical = max(top, bottom)
        let horizontal = max(left, right)

        scrollView.contentInset = UIEdgeInsets(top: vertical, left: horizontal, bottom: vertical, right: horizontal)
    }

    private func applyMode() {
        setCropViewGridIsVisible(mode.state.showGrid)
        setDimmingViewIsVisible(mode.state.showDimming)
        setBlurIsVisible(mode.state.showBlur)
        setCropViewIsVisible(mode.state.showCrop)
        scrollView.isScrollEnabled = mode.state.canScroll
    }

    private func makeConstraints() {
        effectsView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    private func layoutCropViewIfNeeded() {
        if !bounds.isEmpty {
            guard let size = visibleContentFrame.isEmpty ? photo?.size : visibleContentFrame.size else {
                return
            }

            cropView.bounds.size = size
            cropView.center = center
            cropView.allowedBounds = bounds.inset(by: UIEdgeInsets(repeated: 20))
            cropView.clipToBounds(allowedBounds, aspectScaled: true)
            setCropViewIsVisible(mode.state.showCrop)
        }
    }

    private func layoutScrollViewIfNeeded() {
        scrollView.frame = bounds

        if visibleContentFrame.isEmpty {
            scrollView.centerWithView(cropView)
            scrollView.minimumZoomScale = fitScaleForImage(photo)
            scrollView.setZoomScale(scrollView.minimumZoomScale, animated: false)
        } else {
            fitSavedRectToCropView()
        }
    }

    private func fitScaleForImage(_ image: UIImage?) -> CGFloat {
        guard let image = image else {
            return 0
        }

        return max(cropView.frame.height / image.size.height, cropView.frame.width / image.size.width)
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
        scrollView.minimumZoomScale = fitScaleForImage(image)
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
    private var visibleContentFrame: CGRect
}

extension PhotoEditsView {
    func cropViewCorner(at point: CGPoint) -> Corner? {
        return cropView.cornerPosition(at: convert(point, to: cropView))
    }
}

extension PhotoEditsView: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }

    func scrollViewWillBeginZooming(_ scrollView: UIScrollView, with view: UIView?) {
        showMask()
    }

    func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        hideMask()
    }

    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        updateInsets()
    }

    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        showMask()
    }

    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        hideMask()
    }
}

private extension UIScrollView {
    func centerWithView(_ view: UIView, animated: Bool = false) {
        let xOf = contentSize.width / 2 + view.center.x.distance(to: frame.minX)
        let yOf = contentSize.height / 2 + view.center.y.distance(to: frame.minY)

        setContentOffset(CGPoint(x: xOf, y: yOf), animated: animated)
    }
}
