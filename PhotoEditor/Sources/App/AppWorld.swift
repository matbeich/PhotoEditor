//
// Copyright © 2018 Dimasno1. All rights reserved. Product:PhotoEditor
//

import PhotoEditorKit
import UIKit

struct AppWorld {
    var dateProvider = { Date() }
    var photoEditService = PhotoEditorService()
    var appNavigator = AppNavigator()
    var stateStore: StateStore = StateStore(State<AppState>(.initial))
}

extension AppWorld {
    var now: Date {
        return dateProvider()
    }

    var app: UIApplication {
        return .shared
    }
}

var Current = AppWorld()
