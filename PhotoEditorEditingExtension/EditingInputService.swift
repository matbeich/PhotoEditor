//
// Copyright © 2018 Dimasno1. All rights reserved. Product:PhotoEditor
//

import Foundation
import PhotosUI

final class EditingInputService {
    var input: PHContentEditingInput

    init(_ input: PHContentEditingInput = PHContentEditingInput()) {
        self.input = input
    }

    func inputEditingParameters() -> EditingParameters? {
        guard
            let data = input.adjustmentData?.data,
            let object = NSKeyedUnarchiver.unarchiveObject(with: data) as? Data
        else {
            return nil
        }
        
        let parameters = try? PropertyListDecoder().decode(EditingParameters.self, from: object)

        return parameters
    }

    func encodeInData(parameters: EditingParameters) -> Data? {
        guard
            let object = try? PropertyListEncoder().encode(parameters),
            let data = try? NSKeyedArchiver.archivedData(withRootObject: object, requiringSecureCoding: true)
        else {
                return nil
        }

        return data
    }

    func configuredOutput(encodedData: Data) -> PHContentEditingOutput {
        let contentEditingOutput = PHContentEditingOutput(contentEditingInput: input)
        let adjustmentData = PHAdjustmentData(formatIdentifier: identifier, formatVersion: formatVersion, data: encodedData)

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

private extension NSKeyedArchiver {
    enum Keys {
        static let cropedRect = "cropedRect"
        static let filterName = "filterName"
        static let scale = "scale"
    }
}
