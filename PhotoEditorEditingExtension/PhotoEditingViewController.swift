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

    override func viewDidLoad() {
        super.viewDidLoad()

        setup()
    }

    func canHandle(_ adjustmentData: PHAdjustmentData) -> Bool {
        return false
    }

    func startContentEditing(with contentEditingInput: PHContentEditingInput, placeholderImage: UIImage) {
        sceneController.setImage(placeholderImage)
    }

    func finishContentEditing(completionHandler: @escaping (PHContentEditingOutput?) -> Void) {

    }

    func cancelContentEditing() {

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()

        print("memory warning")
    }

    private func setup() {
        sceneController.willMove(toParent: self)
        view.addSubview(sceneController.view)
        sceneController.view.frame = view.bounds
        addChild(sceneController)
        sceneController.didMove(toParent: self)
    }

    private let sceneController = SceneController(context: AppContext())
}
