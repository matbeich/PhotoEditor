//
// Copyright © 2018 Dimasno1. All rights reserved. Product:PhotoEditor
//

import UIKit

typealias Sticker = UIImage

protocol StickersCollectionViewControllerDelegate: AnyObject {
    func stickersCollectionViewController(_ controller: StickersCollectionViewController, didSelectSticker sticker: Sticker)
}

class StickersCollectionViewController: UIViewController {
    weak var delegate: StickersCollectionViewControllerDelegate?

    var stickers: [Sticker] {
        didSet {
            collectionView.reloadData()
        }
    }

    init(stickers: [Sticker] = []) {
        self.stickers = stickers

        super.init(nibName: nil, bundle: nil)
        view.addSubview(collectionView)
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("Not implemented")
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView.frame = view.bounds
    }

    private func setup() {
        collectionView.alwaysBounceHorizontal = true
        collectionView.backgroundColor = .clear
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(StickerCollectionViewCell.self, forCellWithReuseIdentifier: StickerCollectionViewCell.identifier)
    }

    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal

        let view = UICollectionView(frame: self.view.bounds, collectionViewLayout: layout)

        return view
    }()
}

extension StickersCollectionViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return stickers.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FilterCollectionViewCell.identifier, for: indexPath)

        guard let stickerCell = cell as? StickerCollectionViewCell else {
            return cell
        }

        let sticker = stickers[indexPath.row]

        return stickerCell
    }
}

extension StickersCollectionViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        delegate?.stickersCollectionViewController(self, didSelectSticker: stickers[indexPath.row])
    }
}

extension StickersCollectionViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let value = min(collectionView.frame.height, collectionView.frame.width)

        return CGSize(width: value * 0.75, height: value)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }
}
