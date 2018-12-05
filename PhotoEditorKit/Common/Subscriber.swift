//
// Copyright © 2018 Dimasno1. All rights reserved. Product:PhotoEditor
//

import Foundation

public typealias SubscriberID = ObjectIdentifier

public protocol Subscriber: AnyObject {
    var id: SubscriberID { get }
}

public extension Subscriber {
    var id: SubscriberID {
        return ObjectIdentifier(self)
    }
}

extension NSObject: Subscriber {}
