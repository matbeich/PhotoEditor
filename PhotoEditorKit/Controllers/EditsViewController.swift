//
// Copyright © 2018 Dimasno1. All rights reserved. Product: PhotoEditor
//

import SnapKit
import UIKit

public final class EditsViewController: UIViewController {
    public var canCrop: Bool {
        return mode.state.showCrop
    }

    public var mode: EditMode = .normal {
        didSet {
            applyMode()
        }
    }

    public var photo: UIImage? {
        return imageView.image
    }

    public var visibleRect: CGRect {
        return view.convert(cropView.frame, to: imageView)
    }

    public init(frame: CGRect = .zero, image: UIImage? = nil) {
        self.imageView = UIImageView(image: image)
        self.scrollView = UIScrollView(frame: frame)
        self.cropView = CropView(grid: Grid(numberOfRows: 3, numberOfColumns: 3))
        self.visibleContentFrame = .zero

        super.init(nibName: nil, bundle: nil)

        setupScrollView()
        view.addSubview(scrollView)
        view.addSubview(effectsView)
        view.addSubview(cropView)

        applyMode()
        makeConstraints()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("Not implemented")
    }

    override public func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        layoutCropViewIfNeeded()
        layoutScrollViewIfNeeded()
        updateMaskPath()
    }

    public func set(_ photo: UIImage) {
        saveCropedRect()
        imageView = UIImageView(image: photo)
        view.setNeedsDisplay()
    }

    public func showMask() {
        setBlurIsVisible(false)
        setDimmingViewIsVisible(true)
        setCropViewIsVisible(true)
        setCropViewGridIsVisible(true)
    }

    public func hideMask() {
        setBlurIsVisible(true)
        setDimmingViewIsVisible(false)
        setCropViewIsVisible(true)
        setCropViewGridIsVisible(false)
    }

    public func fitCropView() {
        cropView.clipToAllowedBounds(aspectScaled: true)
    }

    public func saveCropedRect() {
        visibleContentFrame = visibleRect
    }

    public func fitSavedRectToCropView() {
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

    public func restoreCropedRect(fromRelative rect: CGRect) {
        guard let size = photo?.size else {
            return
        }

        visibleContentFrame = rect.absolute(in: CGRect(origin: .zero, size: size))
        cropView.frame = rect.absolute(in: view.bounds)
        fitCropView()
        fitSavedRectToCropView()
    }

    public func changeCropViewFrame(using corner: Corner, translation: CGPoint) {
        cropView.changeFrame(using: corner, translation: translation)
    }

    private func updateInsets() {
        let vertical = max(imageView.frame.minY.distance(to: cropView.frame.minY),
                           imageView.frame.maxY.distance(to: cropView.frame.maxY))

        let horizontal = max(imageView.frame.minX.distance(to: cropView.frame.minX),
                             imageView.frame.maxX.distance(to: cropView.frame.maxX))

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
        if !view.bounds.isEmpty {
            guard let size = visibleContentFrame.isEmpty ? photo?.size : visibleContentFrame.size else {
                return
            }

            cropView.bounds.size = size
            cropView.center = view.center
            cropView.allowedBounds = view.bounds.inset(by: UIEdgeInsets(repeated: 20))
            fitCropView()
            setCropViewIsVisible(mode.state.showCrop)
        }
    }

    private func layoutScrollViewIfNeeded() {
        scrollView.frame = view.bounds

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
        scrollView = UIScrollView(frame: view.bounds)
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

        view.insertSubview(scrollView, belowSubview: effectsView)
    }

    private func setDimmingViewIsVisible(_ visible: Bool) {
        updateMaskPath()
        effectsView.setDimmingViewIsVisible(visible)
    }

    private func setBlurIsVisible(_ visible: Bool) {
        updateMaskPath()
        effectsView.setBlurIsVisible(visible)
    }

    private func setCropViewGridIsVisible(_ visible: Bool) {
        cropView.gridIsVisible = visible
    }

    private func setCropViewIsVisible(_ visible: Bool) {
        cropView.isHidden = !visible
        cropView.isUserInteractionEnabled = visible
    }

    private func updateMaskPath() {
        let path = CGMutablePath()
        path.addRect(view.bounds)
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

public extension EditsViewController {
    func cropViewCorner(at point: CGPoint) -> Corner? {
        return cropView.cornerPosition(at: view.convert(point, to: cropView))
    }
}

extension EditsViewController: UIScrollViewDelegate {
    public func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }

    public func scrollViewWillBeginZooming(_ scrollView: UIScrollView, with view: UIView?) {
        showMask()
    }

    public func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        hideMask()
    }

    public func scrollViewDidZoom(_ scrollView: UIScrollView) {
        updateInsets()
    }

    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        showMask()
    }

    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
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
