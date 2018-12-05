//
// Copyright © 2018 Dimasno1. All rights reserved. Product:PhotoEditor
//

import UIKit

public class AppContext {
    public init(photoEditService: PhotoEditorService = PhotoEditorService(),
                stateStore: StateStore<AppState> = StateStore(State<AppState>(.initial))) {
        self.photoEditService = photoEditService
        self.stateStore = stateStore
    }

    public let photoEditService: PhotoEditorService
    public let stateStore: StateStore<AppState>
}

