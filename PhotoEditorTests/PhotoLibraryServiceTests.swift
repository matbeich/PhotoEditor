//
// Copyright © 2018 Dimasno1. All rights reserved. Product:PhotoEditor
//

@testable import PhotoEditor
import XCTest

class PhotoLibraryServiceTests: XCTestCase {
    var service: PhotoLibraryServiceType!

    override func setUp() {
        super.setUp()

        service = PhotoLibraryService(library: .shared())
    }

    override func tearDown() {
        service = nil

        super.tearDown()
    }

    func testCase() {
        service.saveImage(UIImage()) { succes, asset in
            XCTAssertTrue(succes)
        }
    }
}
