//
// Copyright © 2018 Dimasno1. All rights reserved. Product:PhotoEditor
//

import CoreGraphics

struct Config {
    static let cropViewMinDimension: CGFloat = 100.0
    static let toolBarHeight: CGFloat = 59.0
}

enum AppFilters: String, CaseIterable {
    case toneCurve = "CIToneCurve"
    case colorClamp = "CIColorClamp"
    case pointillize = "CIPointillize"
    case spotColor = "CISpotColor"
    case temperatureAndTint = "CITemperatureAndTint"
    case colorCrossPolynomial = "CIColorPolynomial"
    case hueAdjust = "CIHueAdjust"
    case effectNoir = "CIPhotoEffectNoir"
    case edgeWork = "CIEdgeWork"
    case pixelate = "CIPixellate"
    case lineOverlay = "CILineOverlay"
}
