import UIKit
import PlaygroundSupport
import PhotoEditorKit

let img = UIImage(named: "faces.jpg")!
let detector = FaceDetector()

detector.prepareForImage(img)
detector.detectPartsOfFace([.all], on: img) {
    print($0)
}
