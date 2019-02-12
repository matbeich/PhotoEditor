//
// Copyright © 2018 Dimasno1. All rights reserved. Product:PhotoEditor
//

import UIKit
import PhotosUI
import PhotoEditorKit

@objc(PhotoEditingViewController)
class PhotoEditingViewController: UIViewController, PHContentEditingController {
    var shouldShowCancelConfirmation: Bool {
        return true
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        addChild(sceneController, to: view)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    func canHandle(_ adjustmentData: PHAdjustmentData) -> Bool {
        return true
    }

    func startContentEditing(with contentEditingInput: PHContentEditingInput, placeholderImage: UIImage) {
        editingInputService = ContentEditingService(input: contentEditingInput)

        if let image = contentEditingInput.displaySizeImage {
            sceneController.setImage(image)
        } else {
            cancelContentEditing()
        }

        if let edits = editingInputService.editsFromInput() {
            restoreStateWithEdits(edits)
        }
    }

    func finishContentEditing(completionHandler: @escaping (PHContentEditingOutput?) -> Void) {
        guard
            let url = editingInputService.input.fullSizeImageURL,
            let image = UIImage(contentsOfFile: url.path)
        else {
            return
        }

//        context.photoEditService.applyEdits(sceneController.edits, to: image) { [weak self] success, image in
//            guard
//                success,
//                let self = self,
//                let result = image,
//                let jpegData = result.jpegData(compressionQuality: 1.0),
//                let encodedData = self.editingInputService.encodeToData(edits: self.sceneController.edits)
//            else {
//                return
//            }
//
//            let output = self.editingInputService.configureOutputFromData(encodedData)
//
//            do {
//                try jpegData.write(to: output.renderedContentURL)
//            } catch let error {
//                assertionFailure(error.localizedDescription)
//                completionHandler(nil)
//
//                return
//            }

//            completionHandler(output)
        }

    func cancelContentEditing() {

    }

    private func restoreStateWithEdits(_ edits: Edits) {
        if let cropRelative = edits.relativeCutFrame {
            sceneController.restoreCropedRect(fromRelative: cropRelative)
        }

        if let filter = edits.filter {
            sceneController.selectedFilter = filter
        }
    }

    private let context = AppContext()
    private var editingInputService = ContentEditingService()
    private lazy var sceneController = SceneController(context: context)
}
