//
// Copyright © 2018 Dimasno1. All rights reserved. Product:PhotoEditor
//

import UIKit
import PhotoEditorKit

protocol FiltersCollectionViewControllerDelegate: AnyObject {
    func filtersCollectionViewController(_ controller: FiltersCollectionViewController, didSelectFilter filter: EditFilter)
}

class FiltersCollectionViewController: UIViewController {
    weak var delegate: FiltersCollectionViewControllerDelegate?

    var image: UIImage? {
        didSet {
            collectionView.reloadData()
        }
    }

    var filters: [EditFilter] {
        didSet {
            collectionView.reloadData()
        }
    }

    init(image: UIImage? = nil, filters: [EditFilter] = []) {
        self.filters = filters
        self.image = image

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
        collectionView.register(FilterCollectionViewCell.self, forCellWithReuseIdentifier: FilterCollectionViewCell.identifier)
    }

    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal

        let view = UICollectionView(frame: self.view.bounds, collectionViewLayout: layout)

        return view
    }()
}

extension FiltersCollectionViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filters.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FilterCollectionViewCell.identifier, for: indexPath)

        guard let filterCell = cell as? FilterCollectionViewCell, let image = image else {
            return cell
        }

        let filter = filters[indexPath.row]

        Current.photoEditService.asyncApplyFilter(filter, to: image) {
            filterCell.image = $0
            filterCell.filterName = filter.name
        }

        return filterCell
    }
}

extension FiltersCollectionViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        delegate?.filtersCollectionViewController(self, didSelectFilter: filters[indexPath.row])
    }
}

extension FiltersCollectionViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let value = min(collectionView.frame.height, collectionView.frame.width)

        return CGSize(width: value * 0.75, height: value)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }
}
