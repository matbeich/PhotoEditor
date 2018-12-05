//
// Copyright © 2018 Dimasno1. All rights reserved. Product:PhotoEditor
//

import PhotoEditorKit
import UIKit

final class StateStore<T> {
    typealias SubscriberAction = (State<T>) -> Void

    var state: State<T> {
        didSet {
            subscribers.keys.forEach {
                informSubscriber(with: $0)
            }
        }
    }

    init(_ value: State<T>) {
        self.state = value
    }

    func bindSubscriber(with id: SubscriberID, whenChangesPerform action: @escaping SubscriberAction) {
        action(state)

        addSubscriber(with: id, whenChangesPerform: action)
    }

    func addSubscriber(with id: SubscriberID, whenChangesPerform action: @escaping SubscriberAction) {
        if subscribers[id] != nil {
            return
        }

        self.subscribers[id] = action
    }

    func unsubscribeSubscriber(with id: SubscriberID, fireAction: Bool = false) {
        guard let action = subscribers[id] else {
            return
        }

        if fireAction { action(state) }
        subscribers.removeValue(forKey: id)
    }

    func informSubscriber(with id: SubscriberID) {
        guard let action = subscribers[id] else {
            return
        }

        action(state)
    }

    deinit {
        subscribers.keys.forEach {
            informSubscriber(with: $0)
        }

        subscribers.removeAll()
    }

    var subscribers: [SubscriberID: SubscriberAction] = [:]
}
