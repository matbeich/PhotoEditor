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
            guard let sceneController = sceneController, let img = image else {
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
        guard let image = image, let sceneController = sceneController else {
            DispatchQueue.main.async {
                callback(false, nil)
            }

            return
        }

        modifiedImage = image
        let rotatedImageFrame = CGRect(origin: .zero, size: self.modifiedImage?.size ?? .zero)
        let cropZone = sceneController.cutArea.absolute(in: rotatedImageFrame)

        DispatchQueue.global().async { [weak self] in
            guard let self = self else {
                return
            }

            if let angle = sceneController.angle, let image = self.modifiedImage?.zoom(scale: 1.0) {
                self.modifiedImage = self.context.photoEditService.rotateImage(image, byDegrees: angle)
            }

            self.modifiedImage = self.modifiedImage?.cropedZone(cropZone)

            if let filter = sceneController.selectedFilter, let editingImage = self.modifiedImage {
                self.context.photoEditService.asyncApplyFilter(filter, to: editingImage) { image in
                    callback(image != nil, image)
                }
            } else {
                DispatchQueue.main.async {
                    callback(true, self.modifiedImage)
                }
            }
        }
    }

    lazy var rootViewController: UINavigationController = {
        let rootController = UIImagePickerController()
        let controller = rootController
        rootController.delegate = self

        return controller
    }()

    private var image: UIImage?
    private var modifiedImage: UIImage?
    private var sceneController: SceneController?
    private let context = AppContext()
    private let photoLibraryService: PhotoLibraryServiceType = PhotoLibraryService()
}

extension AppNavigator: UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        image = nil
        image = (info[.originalImage] as? UIImage)?.fixOrientation()

        navigateTo(destination: .scene)
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        print("cancel")
    }
}
