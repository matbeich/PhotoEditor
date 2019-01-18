import UIKit
import PlaygroundSupport
import PhotoEditorKit

let img = UIImage(named: "testing.png")
let controller = SceneController(context: AppContext())
controller.setImage(img!)

let rotateControl = RotateAngleControl(startAngle: 0, frame: CGRect(origin: .zero, size: CGSize(width: 300, height: 300)))

let view = UIView(frame: CGRect(origin: .zero, size: CGSize(width: 300, height: 300)))
view.backgroundColor = .white
view.addSubview(rotateControl)

rotateControl.setDotsColor(.black)

PlaygroundPage.current.liveView = view

rotateControl.setDotsNumber(120)
rotateControl.setDotsRadius(0.5)

