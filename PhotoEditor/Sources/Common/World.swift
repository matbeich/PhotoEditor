//
// Copyright © 2018 Dimasno1. All rights reserved. Product:PhotoEditor
//

import UIKit

struct AppWorld {
    var dateProvider = { Date() }
}

extension AppWorld {
    var now: Date {
        return dateProvider()
    }

    var app: UIApplication {
        return .shared
    }
}

var current = AppWorld()
