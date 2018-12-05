//
// Copyright © 2018 Dimasno1. All rights reserved. Product:PhotoEditor
//

import Foundation

public struct State<T> {
    public var value: T

    public init(_ value: T) {
        self.value = value
    }
}
