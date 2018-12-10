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
        imageView.layer.cornerRadius = min(bounds.width, bounds.height) * 0.1
        imageView.contentMode = .scaleAspectFill
        imageView.layer.masksToBounds = true

        textLabel.adjustsFontSizeToFitWidth = false
        textLabel.textAlignment = .center
        textLabel.font = UIFont.systemFont(ofSize: 10)

        contentView.addSubview(stackView)
    }

    private func makeConstraints() {
        stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        imageView.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(imageView.snp.width)
        }
    }

    private(set) lazy var stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [imageView, textLabel])

        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.isUserInteractionEnabled = false
        stackView.spacing = 3

        return stackView
    }()

    private let textLabel = UILabel()
    private let imageView = UIImageView()

}
