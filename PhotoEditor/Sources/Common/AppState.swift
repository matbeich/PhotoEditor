//
// Copyright © 2018 Dimasno1. All rights reserved. Product:PhotoEditor
//

import UIKit

struct AppState {
    var appState: UIApplication.State
    var image: UIImage?
    var editMode: EditMode
}

extension AppState {
    static var initial = AppState(appState: .active, image: nil, editMode: .crop)
}
