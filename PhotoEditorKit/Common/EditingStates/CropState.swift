//
// Copyright © 2018 Dimasno1. All rights reserved. Product:PhotoEditor
//

import Foundation

public class CropState: EditingState {
    public init() {}
    public var showBlur: Bool = false
    public var showDimming: Bool = true
    public var showGrid: Bool = true
    public var showCrop: Bool = true
    public var canScroll: Bool = true
}
