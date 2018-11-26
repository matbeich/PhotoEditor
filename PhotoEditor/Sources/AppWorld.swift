//
// Copyright © 2018 Dimasno1. All rights reserved. Product:PhotoEditor
//

import UIKit

struct AppWorld {
    var dateProvider = { Date() }
    var photoEditService = PhotoEditorService()
    var filterMixer = FilterMixer()
    var stateStore = StateStore.shared
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
