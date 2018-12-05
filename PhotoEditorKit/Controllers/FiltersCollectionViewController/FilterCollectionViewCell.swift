//
// Copyright © 2018 Dimasno1. All rights reserved. Product:PhotoEditor
//

import UIKit

public class FilterCollectionViewCell: UICollectionViewCell {
    public var image: UIImage? {
        didSet {
            imageView.image = image
        }
    }

    public var filterName: String? {
        didSet {
            textLabel.text = filterName
        }
    }

    override public init(frame: CGRect) {
        super.init(frame: frame)

        setup()
        makeConstraints()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override public func prepareForReuse() {
        super.prepareForReuse()

        textLabel.text = nil
        imageView.image = nil
    }

    private func setup() {
        imageView.contentMode = .scaleAspectFill
        imageView.layer.masksToBounds = true
        textLabel.adjustsFontSizeToFitWidth = true

        contentView.addSubview(imageView)
        contentView.addSubview(textLabel)
    }

    private func makeConstraints() {
        imageView.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(imageView.snp.width)
        }

        textLabel.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
        }
    }

    private let textLabel = UILabel()
    private let imageView = UIImageView()
}
