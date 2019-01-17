//
// Copyright © 2018 Dimasno1. All rights reserved. Product:PhotoEditor
//

import UIKit

public class AppContext {
    public init(photoEditService: PhotoEditorService = PhotoEditorService(),
                stateStore: StateStore<AppState> = StateStore(State<AppState>(.initial)),
                calculator: GeometryCalculator = GeometryCalculator()) {
        self.photoEditService = photoEditService
        self.stateStore = stateStore
        self.calculator = calculator
    }

    public let photoEditService: PhotoEditorService
    public let stateStore: StateStore<AppState>
    public let calculator: GeometryCalculator
}

