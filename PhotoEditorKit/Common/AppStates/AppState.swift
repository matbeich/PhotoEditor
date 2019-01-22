//
// Copyright © 2018 Dimasno1. All rights reserved. Product:PhotoEditor
//

import UIKit

public struct AppState {
    public var appState: UIApplication.State
    public var image: UIImage?
    public var editMode: EditMode
    public var performedEdits: Edits
}

public extension AppState {
    static var initial = AppState(
        appState: .active,
        image: nil,
        editMode: .crop,
        performedEdits: .initial
    )
}
