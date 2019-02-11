//
// Copyright © 2018 Dimasno1. All rights reserved. Product:PhotoEditor
//

import Foundation
import PhotosUI
import PhotoEditorKit

final class ContentEditingService {
    var input: PHContentEditingInput

    init(input: PHContentEditingInput = PHContentEditingInput()) {
        self.input = input
    }

    func editsFromInput() -> Edits? {
        guard
            let data = input.adjustmentData?.data,
            let object = NSKeyedUnarchiver.unarchiveObject(with: data) as? Data
        else {
            return nil
        }

        return try? PropertyListDecoder().decode(Edits.self, from: object)
    }

    func encodeToData(edits: Edits) -> Data? {
        guard
            let object = try? PropertyListEncoder().encode(edits),
            let data = try? NSKeyedArchiver.archivedData(withRootObject: object, requiringSecureCoding: true)
        else {
                return nil
        }

        return data
    }

    func configureOutputFromData(_ data: Data) -> PHContentEditingOutput {
        let contentEditingOutput = PHContentEditingOutput(contentEditingInput: input)
        let adjustmentData = PHAdjustmentData(formatIdentifier: identifier, formatVersion: formatVersion, data: data)

        contentEditingOutput.adjustmentData = adjustmentData

        return contentEditingOutput
    }

    private var formatVersion: String {
        if let current = input.adjustmentData?.formatVersion, let doubleValue = Double(current) {
            return "\(doubleValue + 1.0)"
        }

        return "1.0"
    }

    private let identifier = "com.dimasno1.PhotoEditor.PhotoEditor-crop.filter"
}
