//
// Copyright © 2018 Dimasno1. All rights reserved. Product:PhotoEditor
//

import Foundation

public class NormalState: EditingState {
    public init() {}
    public var canScroll: Bool = true
    public var showBlur: Bool = true
    public var showDimming: Bool = false
    public var showGrid: Bool = false
    public var showCrop: Bool = true
}
