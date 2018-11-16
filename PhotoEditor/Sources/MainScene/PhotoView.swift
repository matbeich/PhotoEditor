//
// Copyright © 2018 Dimasno1. All rights reserved. Product: PhotoEditor
//

import SnapKit
import UIKit

class PhotoView: UIView {
    var imageFrame: CGRect {
        return CGRect(origin: CGPoint(x: scrollView.contentOffset.x.magnitude, y: scrollView.contentOffset.y.magnitude), size: scrollView.contentSize)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(scrollView)
        scrollView.addSubview(imageView)

        makeConstraints()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    func set(_ photo: UIImage) {
        imageView.image = photo
        setup()
    }

    private func makeConstraints() {
        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        imageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        setZoomScale()
        centerImage()
    }

    func centerImage() {
        scrollView.centerImage()
    }

    func zoomToRect(_ rect: CGRect, animated: Bool = true) {
        scrollView.zoom(to: rect, animated: animated)
        scrollView.scrollRectToVisible(rect, animated: true)
    }

    private func setZoomScale() {
        let size = CGSize(width: imageView.image?.size.width ?? imageView.frame.size.width,
                          height: imageView.image?.size.height ?? imageView.frame.size.height)

        let minimumZoomScale = min(scrollView.frame.size.width, scrollView.frame.size.height) / max(size.width, size.height)

        scrollView.contentSize = imageView.image?.size ?? imageView.frame.size
        scrollView.minimumZoomScale = minimumZoomScale
        scrollView.maximumZoomScale = minimumZoomScale * 10
        scrollView.zoomScale = minimumZoomScale
    }

    private func setup() {
        scrollView.delegate = self
        scrollView.maximumZoomScale = 2
        scrollView.contentInsetAdjustmentBehavior = .never
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.isScrollEnabled = true

        setZoomScale()
        centerImage()
    }

    private let imageView = UIImageView()
    private let scrollView = UIScrollView()
}

extension PhotoView: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
}

extension UIScrollView {
    func centerImage() {
        let yOffset = contentSize.height / 2 - center.y
        let xOffset = contentSize.width / 2 - center.x

        contentOffset = CGPoint(x: xOffset, y: yOffset)
    }
}
