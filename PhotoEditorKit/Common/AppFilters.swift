//
// Copyright © 2018 Dimasno1. All rights reserved. Product:PhotoEditor
//

import Foundation

public enum AppFilters: String, CaseIterable {
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
