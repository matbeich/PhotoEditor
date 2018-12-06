//
// Copyright © 2018 Dimasno1. All rights reserved. Product:PhotoEditor
//

import UIKit
import Photos
import PhotosUI
import PhotoEditorKit


@objc(PhotoEditingViewController)
class PhotoEditingViewController: UIViewController, PHContentEditingController {

    var shouldShowCancelConfirmation: Bool {
        return true
    }

    func canHandle(_ adjustmentData: PHAdjustmentData) -> Bool {
        return true
    }

    func startContentEditing(with contentEditingInput: PHContentEditingInput, placeholderImage: UIImage) {
        editingInputService = EditingInputService(contentEditingInput)
        let image = contentEditingInput.displaySizeImage
        let editingParameters = editingInputService.inputEditingParameters()

        sceneController.setImage(image!)

        if let cropRelative = editingParameters?.relativeCropRectangle {
            sceneController.restoreCropedRect(fromRelative: cropRelative)
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
        var editingParameters = EditingParameters()

        if let relativeCropZone = sceneController.relativeCropZone {
            img = image.cropedZone(relativeCropZone.toAbsolute(with: image.size))
            editingParameters.relativeCropRectangle = relativeCropZone
        }

        if let filter = sceneController.selectedFilter, let image = img {
            img = context.photoEditService.applyFilter(filter, to: image)
            editingParameters.filterName = filter.name
        }

        let encodedData = editingInputService.encodeInData(parameters: editingParameters)!
        let configuredOutput = editingInputService.configuredOutput(encodedData: encodedData)

        guard
            let result = img,
            let jpegData = result.jpegData(compressionQuality: 1.0)
            else {
                return
        }

        do {
            try jpegData.write(to: configuredOutput.renderedContentURL)
        } catch let error {
            assertionFailure(error.localizedDescription)
            completionHandler(nil)
        }

        completionHandler(configuredOutput)
    }

    func cancelContentEditing() {

    }

    override func viewDidLoad() {
        super.viewDidLoad()
        addChild(sceneController, to: view)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    var image  = UIImage()
    private let context = AppContext()
    private var editingInputService = EditingInputService()
    private lazy var sceneController = SceneController(context: context)
}

private extension CGRect {
    func scaled(by scale: CGFloat) -> CGRect {
        return CGRect(x: origin.x * scale,
                      y: origin.y * scale,
                      width: width * scale, height: height * scale)
    }
}

private extension UIViewController {
    func addChild(_ controller: UIViewController, to container: UIView) {
        controller.view.frame = container.bounds
        controller.willMove(toParent: self)
        view.addSubview(controller.view)
        addChild(controller)
        controller.didMove(toParent: self)
    }
}
