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

        var img: UIImage? = image
        var edits = Edits()
//
//        if let relativeCropZone = sceneController.relativeCropZone {
//            img = image.cropedZone(relativeCropZone.absolute(in: CGRect(origin: .zero, size: image.size)))
//            editingParameters.relativeCropRectangle = relativeCropZone
//        }

        if let filter = sceneController.selectedFilter, let image = img {
            img = context.photoEditService.applyFilter(filter, to: image)
            edits.filterName = filter.name
        }

        guard
            let result = img,
            let jpegData = result.jpegData(compressionQuality: 1.0),
            let encodedData = editingInputService.encodeToData(edits: edits)
        else {
            return
        }

        let output = editingInputService.configureOutputFromData(encodedData)

        do {
            try jpegData.write(to: output.renderedContentURL)
        } catch let error {
            assertionFailure(error.localizedDescription)
            completionHandler(nil)

            return
        }

        completionHandler(output)
    }

    func cancelContentEditing() {

    }

    private func restoreStateWithEdits(_ edits: Edits) {
        if let cropRelative = edits.relativeCutFrame {
            sceneController.restoreCropedRect(fromRelative: cropRelative)
        }

        if let filterName = edits.filterName {
            sceneController.selectedFilter = CIFilter(name: filterName)
        }
    }

    private let context = AppContext()
    private var editingInputService = ContentEditingService()
    private lazy var sceneController = SceneController(context: context)
}
