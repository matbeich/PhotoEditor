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

        return angle == 0 ?
            fitScaleForImage(image) :
            calculator.fitScale(for: image, in: cropView, rotationAngle: angle) / scrollViewScale
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

    lazy var scrollViewOffset: CGPoint = cropView.frame.origin

    public func saveCropedAppearence() {
        guard let size = photo?.size, !size.isEmpty else {
            return
        }

        scrollViewOffset = CGPoint(x: convertedCropViewFrame.origin.x + scrollView.bounds.origin.x,
                                   y: convertedCropViewFrame.origin.y + scrollView.bounds.origin.y)

        let rotatedSize = calculator.boundingBoxOfRectWithSize(size, rotatedByAngle: imageRotationAngle)
        visibleContentFrame = relativeCutRect.absolute(in: CGRect(origin: .zero, size: rotatedSize))
    }

    public func fitSavedRectToCropView() {
        let cropScale = min(cropView.bounds.height / (visibleContentFrame.size.height * scrollViewScale),
                            cropView.bounds.width / (visibleContentFrame.size.width * scrollViewScale))

        let allowedScale = min(scrollView.maximumZoomScale, cropScale)
        let scale = max(1, allowedScale / scrollView.zoomScale)

        scrollView.minimumZoomScale = fitScaleForImageRotated(by: imageRotationAngle)
        scrollView.setZoomScale(allowedScale, animated: false)

        let offsett = CGPoint(x: (scrollViewOffset.x * scale) - convertedCropViewFrame.origin.x,
                              y: (scrollViewOffset.y * scale) - convertedCropViewFrame.origin.y)

        scrollView.setContentOffset(offsett, animated: false)
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
        tuneContentPlacement()
    }

    private func updateInsets() {
        let vertical = convertedCropViewFrame.origin.y
        let horizontal = convertedCropViewFrame.origin.x

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
        scrollView.minimumZoomScale = fitScaleForImageRotated(by: imageRotationAngle)
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
        let imagePositionInCenterOfScrollView = scrollView.contentPositionInCenter

        let photoBoundingBox = calculator.boundingBoxOfRectWithSize(photoFrame.size,
                                                                    rotatedByAngle: imageRotationAngle)

        let contentSize = CGSize(width: scrollView.contentSize.width * scrollViewScale,
                                 height: scrollView.contentSize.height * scrollViewScale)

        let contentBoundingBox = calculator.boundingBoxOfRectWithSize(contentSize,
                                                                      rotatedByAngle: imageRotationAngle)

        let center = calculator.boundedBoxPositionOfPoint(imagePositionInCenterOfScrollView,
                                                          afterRotationOfRect: photoFrame,
                                                          byAngle: imageRotationAngle)

        let relativeSize = CGSize(width: cropView.bounds.width / contentBoundingBox.width,
                                  height: cropView.bounds.height / contentBoundingBox.height)

        let relativeOrigin = CGPoint(x: (center.x / photoBoundingBox.width) - relativeSize.width / 2,
                                     y: (center.y / photoBoundingBox.height) - relativeSize.height / 2)

        return CGRect(origin: relativeOrigin, size: relativeSize)
    }

    private func tuneContentPlacement() {
        let shouldZoomToFitHeight = convertedCropViewFrame.height > scrollView.contentFrame.height
        let shouldZoomToFitWidth = convertedCropViewFrame.width > scrollView.contentFrame.width
        let shoudUpdateZoom = shouldZoomToFitWidth || shouldZoomToFitHeight

        let shouldMoveUp = convertedCropViewFrame.minY < scrollView.contentFrame.minY
        let shouldMoveDown = convertedCropViewFrame.maxY > scrollView.contentFrame.maxY
        let shouldMoveLeft = convertedCropViewFrame.minX < scrollView.contentFrame.minX
        let shouldMoveRight = convertedCropViewFrame.maxX > scrollView.contentFrame.maxX

        if shoudUpdateZoom {
            setMinimumZoomScale()
            let action: KeepInBoundsAction = shouldZoomToFitWidth ? .zoomFitWidth : .zoomFitHeight
            scrollView.dragContentToCorrespondingEdge(of: convertedCropViewFrame, using: action)
        }

        if shouldMoveUp {
            scrollView.dragContentToCorrespondingEdge(of: convertedCropViewFrame, using: .dragUp)
        }

        if shouldMoveLeft {
            scrollView.dragContentToCorrespondingEdge(of: convertedCropViewFrame, using: .dragLeft)
        }

        if shouldMoveDown {
            scrollView.dragContentToCorrespondingEdge(of: convertedCropViewFrame, using: .dragDown)
        }

        if shouldMoveRight {
            scrollView.dragContentToCorrespondingEdge(of: convertedCropViewFrame, using: .dragRight)
        }
    }

    private var imageView: UIImageView {
        didSet {
            setupScrollView()
        }
    }

    private var convertedCropViewFrame: CGRect {
        return calculator.boundingBox(of: cropView.frame, convertedToOriginalFrameOfTransformedView: scrollView)
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

    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        showMask()
    }

    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        hideMask()
    }
}

private extension UIScrollView {
    var contentFrame: CGRect {
        return CGRect(x: -bounds.origin.x,
                      y: -bounds.origin.y,
                      width: contentSize.width,
                      height: contentSize.height)
    }

    func dragContentToCorrespondingEdge(of cropFrame: CGRect, using action: KeepInBoundsAction) {
        setContentOffset(action.contentOffsetInScrollView(self, forCropFrame: cropFrame, imageFrame: contentFrame), animated: false)
    }

    func centerWithView(_ view: UIView, animated: Bool = false) {
        let xOf = contentSize.width / 2 + view.center.x.distance(to: frame.minX)
        let yOf = contentSize.height / 2 + view.center.y.distance(to: frame.minY)

        setContentOffset(CGPoint(x: xOf, y: yOf), animated: animated)
    }
}
