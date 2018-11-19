//
// Copyright © 2018 Dimasno1. All rights reserved. Product: PhotoEditor
//

import SnapKit
import UIKit

class PhotoEditsView: UIView {
    var image: UIImage? {
        return imageView.image
    }

    init(frame: CGRect = .zero, image: UIImage? = nil) {
        self.imageView = UIImageView(image: image)
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

        setZoomScale()
        layoutCropViewIfNeeded()
        updateMaskPath()
    }

    private func setup() {
        cropView = CropView(frame: bounds, grid: Grid(numberOfRows: 3, numberOfColumns: 3))
        setBlurIsVisible(true)
        setCropViewGridIsVisible(false)

        imageView.contentMode = .scaleAspectFit
        imageView.frame = scrollView.frame
        imageView.bounds.size = scrollView.bounds.size

        scrollView.delegate = self
        scrollView.maximumZoomScale = 2
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.isScrollEnabled = true
    }

    func layoutCropViewIfNeeded() {
        if cropView.frame.isEmpty {
            cropView.frame = bounds
            cropView.allowedBounds = bounds.inset(by: UIEdgeInsets(repeated: 10))
        }
    }

    func changeCropViewFrame(using corner: Corner, translation: CGPoint) {
        cropView.changeFrame(using: corner, translation: translation)
    }

    func fitCropView() {
        cropView.fitInBounds(bounds, aspectScaled: true)
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
        imageView.frame = CGRect(origin: .zero, size: photo.size)
        scrollView.contentSize = photo.size
        setZoomScale()
        scrollView.centerImage()
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
            make.edges.equalToSuperview()
        }
    }

    private func setZoomScale() {
        let size = CGSize(width: imageView.image?.size.width ?? imageView.frame.size.width,
                          height: imageView.image?.size.height ?? imageView.frame.size.height)

        let minimumZoomScale = min(scrollView.frame.size.width, scrollView.frame.size.height) / max(size.width, size.height)

        scrollView.minimumZoomScale = minimumZoomScale
        scrollView.maximumZoomScale = minimumZoomScale * 10
        scrollView.zoomScale = minimumZoomScale
        scrollView.centerImage()
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

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        setBlurIsVisible(true)
    }

    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        setCropViewGridIsVisible(true)
        setBlurIsVisible(false)
    }

    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        setCropViewGridIsVisible(false)
    }
}

extension UIScrollView {
    func centerImage(animated: Bool = false) {
        let yOffset = contentSize.height / 2 - center.y
        let xOffset = contentSize.width / 2 - center.x

        setContentOffset(CGPoint(x: xOffset, y: yOffset), animated: animated)
    }
}
