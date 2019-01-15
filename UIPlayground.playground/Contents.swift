import UIKit
import PlaygroundSupport
import PhotoEditorKit

let img = UIImage(named: "testing.png")
let controller = SceneController(context: AppContext())
controller.setImage(img!)


PlaygroundPage.current.liveView = controller.view



