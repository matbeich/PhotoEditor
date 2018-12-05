//
// Copyright © 2018 Dimasno1. All rights reserved. Product:  CollageMaker
//

import SnapKit
import UIKit

public class BarButtonItem: UIControl {
    override public var isHighlighted: Bool {
        didSet {
            layer.opacity = isHighlighted ? 0.5 : 1
            imageView.image = isHighlighted ? tappedStateImage : normalStateImage
        }
    }

    public let title: String
    public let normalStateImage: UIImage?
    public let tappedStateImage: UIImage?

    public init(title: String, image: UIImage?, tappedImage: UIImage? = nil) {
        self.title = title
        self.normalStateImage = image

        if let tappedImage = tappedImage {
            self.tappedStateImage = tappedImage
        } else {
            self.tappedStateImage = image
        }

        super.init(frame: .zero)

        addSubview(stackView)
        setup()
        makeConstraints()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setup() {
        imageView.image = normalStateImage
        imageView.contentMode = .scaleAspectFit

        titleLabel.text = title
        titleLabel.textAlignment = .center
        titleLabel.adjustsFontSizeToFitWidth = true
    }

    private func makeConstraints() {
        stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        imageView.snp.makeConstraints { make in
            make.width.equalTo(25)
            make.height.equalTo(imageView.snp.width)
        }
    }

    private lazy var stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [imageView, titleLabel])
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.isUserInteractionEnabled = false
        stackView.spacing = 5

        return stackView
    }()

    private let titleLabel = UILabel()
    private let imageView = UIImageView()
}

extension UIImage {
    static var none: UIImage {
        return UIImage()
    }
}
