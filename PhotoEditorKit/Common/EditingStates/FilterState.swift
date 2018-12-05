//
// Copyright © 2018 Dimasno1. All rights reserved. Product: PhotoEditor
//

import Foundation

public class FilterState: EditingState {
    public init() {}
    public var showBlur: Bool = true
    public var showDimming: Bool = true
    public var showGrid: Bool = false
    public var showCrop: Bool = false
    public var canScroll: Bool = false
}
