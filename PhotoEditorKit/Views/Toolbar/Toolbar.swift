//
// Copyright © 2018 Dimasno1. All rights reserved. Product:  CollageMaker
//

import SnapKit
import UIKit

public protocol ToolbarDelegate: AnyObject {
    func toolbar(_ toolbar: Toolbar, itemTapped: BarButtonItem)
}

public class Toolbar: UIView {
    public weak var delegate: ToolbarDelegate?

    public init(frame: CGRect = .zero, barItems: [BarButtonItem] = []) {
        self.barItems = barItems
        super.init(frame: frame)

        tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(itemTapped(_:)))
        barItems.forEach { addCollageBarItem($0) }

        addSubview(buttonsStackView)
        addGestureRecognizer(tapGestureRecognizer)

        makeConstraints()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("Not implemented")
    }

    public func addCollageBarItem(_ item: BarButtonItem) {
        item.tag = buttonsStackView.arrangedSubviews.count
        buttonsStackView.addArrangedSubview(item)
    }

    private func makeConstraints() {
        buttonsStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5))
        }
    }

    @objc private func itemTapped(_ recoginzer: UITapGestureRecognizer) {
        guard let item = itemForPoint(recoginzer.location(in: self)) else {
            return
        }

        delegate?.toolbar(self, itemTapped: item)
    }

    private func itemForPoint(_ point: CGPoint) -> BarButtonItem? {
        return buttonsStackView.arrangedSubviews.first(where: { $0.frame.contains(point) }) as? BarButtonItem
    }

    private lazy var buttonsStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [])

        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 5

        return stackView
    }()

    private let barItems: [BarButtonItem]
    private lazy var tapGestureRecognizer = UITapGestureRecognizer()
}
