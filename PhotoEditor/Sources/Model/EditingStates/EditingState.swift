//
// Copyright © 2018 Dimasno1. All rights reserved. Product: PhotoEditor
//

import Foundation

protocol EditingState {
    var canScroll: Bool { get }
    var showBlur: Bool { get }
    var showDimming: Bool { get }
    var showGrid: Bool { get }
    var showCrop: Bool { get }
}
