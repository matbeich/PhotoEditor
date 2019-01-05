//
// Copyright © 2018 Dimasno1. All rights reserved. Product: PhotoEditor
//

import SnapKit
import UIKit

public final class EditsViewController: UIViewController {

    public private(set) var imageRotationAngle: CGFloat = 0
    public private(set) var scrollViewScale: CGFloat = 1

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

    public var relativeCutRect: CGRect {
        return calculateCutRect()
    }

    public init(frame: CGRect = .zero, image: UIImage? = nil) {
        self.imageView = UIImageView(image: image)
        self.scrollView = UIScrollView(frame: frame)
        self.cropView = CropView(grid: Grid(numberOfRows: 3, numberOfColumns: 3))
        self.visibleContentFrame = .zero

        super.init(nibName: nil, bundle: nil)

        setupScrollView()
        view.layer.masksToBounds = true
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
        saveCropedAppearence()
        imageView = UIImageView(image: photo)
    }

    public func rotatePhoto(by angle: CGFloat) {
        scrollViewScale = zoomForRotation(by: angle)

        let transform = CGAffineTransform.identity
        let scaling = transform.scaledBy(x: scrollViewScale, y: scrollViewScale)
        let rotating = scaling.rotated(by: angle.inRadians())

        let minScale = fitScaleForImageRotated(by: angle)

        scrollView.transform = rotating
        scrollView.minimumZoomScale = minScale

        if scrollView.zoomScale < scrollView.minimumZoomScale {
            scrollView.zoomScale = minScale
        }

        updateInsets()
        self.imageRotationAngle = angle
    }

    private func zoomForRotation(by angle: CGFloat) -> CGFloat {
        let size = calculator.boundingBoxOfRectWithSize(scrollView.bounds.size, rotatedByAngle: angle)

        return max(size.width / scrollView.bounds.width,
                   size.height / scrollView.bounds.height)
    }

    private func fitScaleForImageRotated(by angle: CGFloat) -> CGFloat {
        guard let image = imageView.image else {
            return 1
        }

        return calculator.fitScale(for: image, in: cropView, rotationAngle: angle) / scrollViewScale
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

    public func saveCropedAppearence() {
        guard let size = photo?.size, !size.isEmpty else {
            return
        }

        let rotatedSize = calculator.boundingBoxOfRectWithSize(size, rotatedByAngle: imageRotationAngle)
        let frame = CGRect(origin: .zero, size: rotatedSize)

        visibleContentFrame = relativeCutRect.absolute(in: frame)
    }

    public func fitSavedRectToCropView() {
        let scale = min(scrollView.maximumZoomScale,
                        min(cropView.frame.height / visibleContentFrame.size.height,
                            cropView.frame.width / visibleContentFrame.size.width))

        let cropViewOffset = CGPoint(x: cropView.frame.origin.x.distance(to: scrollView.frame.origin.x),
                                     y: cropView.frame.origin.y.distance(to: scrollView.frame.origin.y))

        let offset = visibleContentFrame.origin
            .applying(CGAffineTransform(scaleX: scale, y: scale))
            .applying(CGAffineTransform(translationX: cropViewOffset.x, y: cropViewOffset.y))

        scrollView.minimumZoomScale = fitScaleForImageRotated(by: imageRotationAngle)
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
        keepImageInsideCropView()
    }

    private func updateInsets() {
        let frame = calculator.boundingBox(of: cropView.frame, convertedToBoundsOf: scrollView)

        let vertical = frame.origin.y
        let horizontal = frame.origin.x

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
            setMinimumZoomScale()
            updateInsets()
        } else {
            fitSavedRectToCropView()
        }
    }

    private func keepImageInsideCropView() {
        let imageViewFrame = scrollView.convert(imageView.frame, to: view)
        let frame = calculator.boundingBox(of: cropView.frame, convertedToBoundsOf: scrollView)

        let shouldZoomToFitHeight = frame.height > imageViewFrame.height
        let shouldZoomToFitWidth = frame.width > imageViewFrame.width
        let shoudUpdateZoom = shouldZoomToFitWidth || shouldZoomToFitHeight
        let shouldMoveUp = frame.minY - imageViewFrame.minY < -2
        let shouldMoveDown = frame.maxY > imageViewFrame.maxY
        let shouldMoveLeft = frame.minX - imageViewFrame.minX < -2
        let shouldMoveRight = frame.maxX > imageViewFrame.maxX

        if shoudUpdateZoom {
            setMinimumZoomScale()
            shouldZoomToFitWidth ? scrollView.centerHorizontallyWithView(cropView) : scrollView.centerVerticallyWithView(cropView)
        }

        if shouldMoveUp && !shoudUpdateZoom{
            let yOffset = scrollView.contentOffset.y - (frame.minY - imageViewFrame.minY)
            scrollView.contentOffset = CGPoint(x: scrollView.contentOffset.x, y: yOffset)
        }

        if shouldMoveLeft && !shoudUpdateZoom{
            let xOffset = scrollView.contentOffset.x - (frame.minX - imageViewFrame.minX)
            scrollView.contentOffset = CGPoint(x: xOffset, y: scrollView.contentOffset.y)
        }

        if shouldMoveDown && !shoudUpdateZoom {
            let yOffset = scrollView.contentOffset.y - (frame.maxY - imageViewFrame.maxY)
            scrollView.contentOffset = CGPoint(x: scrollView.contentOffset.x, y: yOffset)
        }

        if shouldMoveRight && !shoudUpdateZoom {
            let xOffset = scrollView.contentOffset.x - (frame.maxX - imageViewFrame.maxX)
            scrollView.contentOffset = CGPoint(x: xOffset, y: scrollView.contentOffset.y)
        }
    }

    private func setupScrollView() {
        scrollView.removeFromSuperview()
        scrollView = UIScrollView(frame: view.bounds)
        scrollView.contentSize = photo?.size ?? .zero
        scrollView.delegate = self
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.isScrollEnabled = true
        scrollView.maximumZoomScale = 5
        setMinimumZoomScale()
        scrollView.contentInsetAdjustmentBehavior = .automatic
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

    private func setMinimumZoomScale() {
        scrollView.minimumZoomScale = fitScaleForImage(photo)
        scrollView.zoomScale = scrollView.minimumZoomScale
    }

    private func fitScaleForImage(_ image: UIImage?) -> CGFloat {
        guard let image = image else {
            return 0
        }

        return max(cropView.frame.height / image.size.height, cropView.frame.width / image.size.width)
    }

    private func updateMaskPath() {
        let path = CGMutablePath()
        path.addRect(view.bounds)
        path.addRect(cropView.frame)

        effectsView.setMaskPath(path)
    }

    private func calculateCutRect() -> CGRect {
        let photoFrame = CGRect(origin: .zero, size: photo?.size ?? .zero)
        let scrollViewFocusPoint = calculator.focusedPoint(by: scrollView).absolute(in: photoFrame)

        let photoBoundingBox = calculator.boundingBoxOfRectWithSize(photoFrame.size,
                                                          rotatedByAngle: imageRotationAngle)

        let contentSize = CGSize(width: scrollView.contentSize.width * scrollViewScale,
                                 height: scrollView.contentSize.height * scrollViewScale)

        let contentBoundingBox = calculator.boundingBoxOfRectWithSize(contentSize,
                                                                      rotatedByAngle: imageRotationAngle)

        let center = calculator.boundedBoxPositionOfPoint(scrollViewFocusPoint,
                                                          afterRotationOfRect: photoFrame,
                                                          byAngle: imageRotationAngle)

        let relativeSize = CGSize(width: cropView.bounds.width / contentBoundingBox.width,
                                  height: cropView.bounds.height / contentBoundingBox.height)

        let relativeOrigin = CGPoint(x: (center.x / photoBoundingBox.width) - relativeSize.width / 2,
                                     y: (center.y / photoBoundingBox.height) - relativeSize.height / 2)

        return CGRect(origin: relativeOrigin, size: relativeSize)
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
    private let calculator = GeometryCalculator()
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
    }

    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        showMask()
    }

    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        hideMask()
    }
}

private extension UIScrollView {
    func centerVerticallyWithView(_ view: UIView, animated: Bool = false) {
        let xOf = contentOffset.x
        let yOf = contentSize.height / 2 + view.center.y.distance(to: frame.minY)

        setContentOffset(CGPoint(x: xOf, y: yOf), animated: animated)
    }

    func centerHorizontallyWithView(_ view: UIView, animated: Bool = false) {
        let xOf = contentSize.width / 2 + view.center.x.distance(to: frame.minX)
        let yOf = contentOffset.y

        setContentOffset(CGPoint(x: xOf, y: yOf), animated: animated)
    }

    func centerWithView(_ view: UIView, animated: Bool = false) {
        let xOf = contentSize.width / 2 + view.center.x.distance(to: frame.minX)
        let yOf = contentSize.height / 2 + view.center.y.distance(to: frame.minY)

        setContentOffset(CGPoint(x: xOf, y: yOf), animated: animated)
    }
}
