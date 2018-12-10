//
// Copyright © 2018 Dimasno1. All rights reserved. Product:PhotoEditor
//

import Foundation

public extension String {
    func camelCaseToWords() -> String {
        return unicodeScalars.reduce("") {
            let separator = CharacterSet.uppercaseLetters.contains($1) ? " " : ""

            return ($0 + separator + "\($1)")
        }
    }
}
