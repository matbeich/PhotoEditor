//
// Copyright © 2018 Dimasno1. All rights reserved. Product:PhotoEditor
//

import UIKit

class FilterCollectionViewCell: UICollectionViewCell {
    static var identifier: String {
        return String(describing: self)
    }

    var image: UIImage? {
        didSet {
            imageView.image = image
        }
    }

    var filterName: String? {
        didSet {
            textLabel.text = filterName
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        setup()
        makeConstraints()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        textLabel.text = nil
        imageView.image = nil
    }

    private func setup() {
        imageView.contentMode = .scaleAspectFit
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
