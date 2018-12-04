//
// Copyright © 2018 Dimasno1. All rights reserved. Product:PhotoEditor
//

import Foundation

typealias SubscriberID = ObjectIdentifier

protocol Subscriber: AnyObject {
    var id: SubscriberID { get }
}

extension Subscriber {
    var id: SubscriberID {
        return ObjectIdentifier(self)
    }
}

extension NSObject: Subscriber {}
