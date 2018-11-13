//
// Copyright © 2018 Dimasno1. All rights reserved. Product: PhotoEditor
//

import SnapKit
import UIKit

class PhotoView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)

        addSubview(scrollView)
        scrollView.addSubview(imageView)

        makeConstraints()
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("Not implemented")
    }

    func set(_ photo: UIImage) {
        imageView.image = photo
    }

    private func makeConstraints() {
        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        imageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    private func setup() {
        scrollView.contentSize = imageView.image?.size ?? imageView.frame.size
    }

    private let imageView = UIImageView()
    private let scrollView = UIScrollView()
}
