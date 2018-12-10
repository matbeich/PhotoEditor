//
// Copyright © 2018 Dimasno1. All rights reserved. Product:PhotoEditor
//

import Photos
import UIKit

protocol PhotoLibraryServiceType {
    typealias PhotoCompletion = (Bool, PHAsset?) -> Void
    func saveImage(_ image: UIImage, callback: @escaping PhotoCompletion)
}

final class PhotoLibraryService: PhotoLibraryServiceType {
    init(library: PHPhotoLibrary = .shared()) {
        self.photoLibrary = library
    }

    func saveImage(_ image: UIImage, callback: @escaping PhotoCompletion) {
        var placeholder = PHObjectPlaceholder()

        let changeBlock = {
            let creationRequest = PHAssetChangeRequest.creationRequestForAsset(from: image)
            let addAssetRequest = PHAssetCollectionChangeRequest(for: PHAssetCollection())

            guard let assetPaceholder = creationRequest.placeholderForCreatedAsset else {
                callback(false, nil)
                return
            }

            placeholder = assetPaceholder
            addAssetRequest?.addAssets([placeholder] as NSArray)
        }

        photoLibrary.performChanges(changeBlock) { success, _ in
            let asset = PHAsset.fetchAssets(withLocalIdentifiers: [placeholder.localIdentifier], options: nil).firstObject

            DispatchQueue.main.async { callback(success, asset) }
        }
    }

    private let photoLibrary: PHPhotoLibrary
}
