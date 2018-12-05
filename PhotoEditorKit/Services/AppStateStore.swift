//
// Copyright © 2018 Dimasno1. All rights reserved. Product:PhotoEditor
//

import Foundation

public final class StateStore<T> {
    public typealias SubscriberAction = (State<T>) -> Void

    public var state: State<T> {
        didSet {
            subscribers.keys.forEach {
                informSubscriber(with: $0)
            }
        }
    }

    public init(_ value: State<T>) {
        self.state = value
    }

    public func bindSubscriber(with id: SubscriberID, whenChangesPerform action: @escaping SubscriberAction) {
        action(state)

        addSubscriber(with: id, whenChangesPerform: action)
    }

    public func addSubscriber(with id: SubscriberID, whenChangesPerform action: @escaping SubscriberAction) {
        if subscribers[id] != nil {
            return
        }

        self.subscribers[id] = action
    }

    public func unsubscribeSubscriber(with id: SubscriberID, fireAction: Bool = false) {
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

    public var subscribers: [SubscriberID: SubscriberAction] = [:]
}
