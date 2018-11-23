//
// Copyright © 2018 Dimasno1. All rights reserved. Product:PhotoEditor
//

import UIKit

class FiltersCollectionViewController: UIViewController {
    var filters: [CIFilter] {
        didSet {
            collectionView.reloadData()
        }
    }

    init(filters: [CIFilter]) {
        self.filters = filters

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("Not implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(collectionView)
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()

        collectionView.frame = view.bounds
    }

    private func setup() {
        collectionView.register(FilterCollectionViewCell.self, forCellWithReuseIdentifier: FilterCollectionViewCell.identifier)
        collectionView.delegate = self
    }

    private let collectionView = UICollectionView()
}

extension FiltersCollectionViewController: UICollectionViewDelegate {
}

extension FiltersCollectionViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filters.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FilterCollectionViewCell.identifier, for: indexPath)

        guard let filterCell = cell as? FilterCollectionViewCell else {
            return cell
        }

        return filterCell
    }
}
