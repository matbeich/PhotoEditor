//
// Copyright © 2018 Dimasno1. All rights reserved. Product:PhotoEditor
//

import UIKit

public protocol FiltersCollectionViewControllerDelegate: AnyObject {
    func filtersCollectionViewController(_ controller: FiltersCollectionViewController, didSelectFilter filter: AppFilter)
}

public class FiltersCollectionViewController: UIViewController {
    public weak var delegate: FiltersCollectionViewControllerDelegate?

    public var image: UIImage? {
        didSet {
            collectionView.reloadData()
        }
    }

    public var filters: [AppFilter] {
        didSet {
            collectionView.reloadData()
        }
    }

    public init(context: AppContext,image: UIImage? = nil, filters: [AppFilter] = []) {
        self.filters = filters
        self.image = image
        self.context = context

        super.init(nibName: nil, bundle: nil)
        view.addSubview(collectionView)
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("Not implemented")
    }

    override public func viewDidLayoutSubviews() {
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

    public lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal

        let view = UICollectionView(frame: self.view.bounds, collectionViewLayout: layout)

        return view
    }()

    private let context: AppContext
}

extension FiltersCollectionViewController: UICollectionViewDataSource {
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filters.count
    }

    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FilterCollectionViewCell.identifier, for: indexPath)

        guard let filterCell = cell as? FilterCollectionViewCell, let image = image else {
            return cell
        }

        let filter = filters[indexPath.row]

        context.photoEditService.asyncApplyFilter(filter, to: image) {
            filterCell.image = $0
            filterCell.filterName = filter.rawValue
        }

        return filterCell
    }
}

extension FiltersCollectionViewController: UICollectionViewDelegate {
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        delegate?.filtersCollectionViewController(self, didSelectFilter: filters[indexPath.row])
    }
}

extension FiltersCollectionViewController: UICollectionViewDelegateFlowLayout {
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let value = min(collectionView.frame.height, collectionView.frame.width)

        return CGSize(width: value * 0.75, height: value * 0.9)
    }

    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }

    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5)
    }
}
