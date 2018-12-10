//
// Copyright © 2018 Dimasno1. All rights reserved. Product:PhotoEditor
//

import PhotoEditorKit
import Photos
import UIKit
import Utils

class AppNavigator: NSObject {
    enum Destination {
        case scene
    }

    func navigateTo(destination: Destination) {
        switch destination {
        case .scene:
            let vc = SceneController(context: context)

            rootViewController.push(vc, animated: true)
            guard let img = image?.fixOrientation() else {
                return
            }

            vc.setImage(img)
        }
    }

    lazy var rootViewController: UINavigationController = {
        let rootController = UIImagePickerController()
        let controller = rootController

        rootController.delegate = self

        return controller
    }()

    private var asset: PHAsset?
    private var image: UIImage?
    private let context = AppContext()
}

extension AppNavigator: UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        image = info[.originalImage] as? UIImage
        asset = info[.phAsset] as? PHAsset

        navigateTo(destination: .scene)
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        print("cancel")
    }
}
