//
// Copyright © 2018 Dimasno1. All rights reserved. Product:PhotoEditor
//

import Foundation

public enum EditMode {
    case crop
    case filter
    case normal
    //    case stickers

    public var state: EditingState {
        switch self {
        case .crop: return CropState()
        case .filter: return FilterState()
        case .normal: return NormalState()
        }
    }
}
