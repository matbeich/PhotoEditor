//
// Copyright © 2018 Dimasno1. All rights reserved. Product:PhotoEditor
//
//
//  Store.swift
//  StateApp
//
//  Created by Admin on 11/26/18.
//  Copyright © 2018 Admin. All rights reserved.
//

import UIKit

enum AppMode {
    case normal
    case superuser
    case restricted
}

struct AppState {
    var appState: UIApplication.State
    var mode: AppMode
    var editMode: EditMode
}

extension AppState {
    static var initial = AppState(appState: .active, mode: .normal, editMode: .crop)
}

final class StateStore {
    var appstate: AppState {
        didSet {
            subscribers.keys.forEach {
                informSubscriber(with: $0)
            }
        }
    }

    init(state: AppState) {
        self.appstate = state
    }

    func informSubscriber(with id: Int) {
        guard let action = subscribers[id] else {
            return
        }

        action(appstate)
    }

    func unsubscribeSubscriber(with id: Int) {
        guard let action = subscribers[id] else {
            return
        }

        action(appstate)
        subscribers.removeValue(forKey: id)
    }

    func addSubscriber(_ subscriber: Subscriber, changeAction: @escaping SubscriberAction) {
        if subscribers[subscriber.subscriberID] != nil {
            return
        }

        self.subscribers[subscriber.subscriberID] = changeAction
    }

    deinit {
        subscribers.keys.forEach {
            informSubscriber(with: $0)
        }

        subscribers.removeAll()
    }

    var subscribers: [Int: SubscriberAction] = [:]
}

typealias SubscriberAction = (AppState) -> Void

protocol Subscriber: AnyObject {
    var subscriberID: Int { get }
    func subscribe(to stateStore: StateStore, performWhenChanged: @escaping SubscriberAction)
}

extension Subscriber {
    var subscriberID: Int {
        return Unmanaged.passUnretained(self).toOpaque().hashValue
    }

    func subscribe(to stateStore: StateStore, performWhenChanged: @escaping SubscriberAction) {
        stateStore.addSubscriber(self, changeAction: performWhenChanged)
    }

    func bind(to stateStore: StateStore, performWhenChanged: @escaping SubscriberAction) {
        stateStore.addSubscriber(self, changeAction: performWhenChanged)
    }

    func unsubscribe(from stateStore: StateStore) {
        stateStore.unsubscribeSubscriber(with: subscriberID)
    }
}

extension StateStore {
    static var shared = StateStore(state: .initial)
}

extension NSObject: Subscriber {}
