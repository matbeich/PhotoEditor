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
            sceneController = SceneController(context: context)
            guard let sceneController = sceneController, let img = image?.fixOrientation() else {
                return
            }

            setupScene()
            rootViewController.push(sceneController, animated: true)
            sceneController.setImage(img)
        }
    }

    @objc private func saveImage() {
        applyChangesIfNeeded { [weak self] succes, image in
            let message = succes ? "Success" : "Error"

            guard let self = self, let image = image else {
                return
            }

            self.photoLibraryService.saveImage(image) { succes, _ in
                Alert.popUpMessage(message, duration: 1, in: self.rootViewController)
            }
        }
    }

    private func setupScene() {
        sceneController?.navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .save,
            target: self,
            action: #selector(saveImage)
        )
    }

    private func applyChangesIfNeeded(callback: @escaping (Bool, UIImage?) -> Void) {
        guard let image = image else {
            callback(false, nil)
            return
        }

        var img: UIImage? = image

        if let scrollViewCropZone = sceneController?.relativeCropZone, let size = sceneController?.size {
            let cropRect = scrollViewCropZone.absolute(in: CGRect(origin: .zero, size: size))

            img = context.photoEditService.drawImage(img!, with: size, rect: cropRect)
        }

        if let angle = sceneController?.angle {
            let rotated = context.photoEditService.rotateImage(img!, byDegrees: angle)
            img = rotated
        }

        if let cutArea = sceneController?.cropViewCutArea, let size = img?.size {
            let zone = cutArea.absolute(in: CGRect(origin: .zero, size: size))

            img = img?.cropedZone(zone)
        }

        if let filter = sceneController?.selectedFilter, let editingImage = img {
            context.photoEditService.asyncApplyFilter(filter, to: editingImage) { image in
                callback(image != nil, image)
            }
        } else {
            callback(true, img)
        }
    }

    lazy var rootViewController: UINavigationController = {
        let rootController = UIImagePickerController()
        let controller = rootController
        rootController.delegate = self

        return controller
    }()

    private var image: UIImage?
    private var sceneController: SceneController?
    private let context = AppContext()
    private let calc = GeometryCalculator()
    private let photoLibraryService: PhotoLibraryServiceType = PhotoLibraryService()
}

extension AppNavigator: UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        image = nil
        image = info[.originalImage] as? UIImage

        navigateTo(destination: .scene)
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        print("cancel")
    }
}

public extension CGSize {
    func scaledBy(_ value: CGFloat) -> CGSize {
        return CGSize(width: width * value, height: height * value)
    }
}
