//
//  Events.swift
//  ModelManager
//
//  Created by Masaki Sueda on 2015/08/17.
//  Copyright (c) 2015 Masaki Sueda. All rights reserved.
//

import Foundation

public typealias TSTEventHandler = (value: Any, forKeyPath: String?) -> Void

public class TSTEvents:NSObject {
    private var _events:[TSTEventObject] = []
    public var _observing:[String:TSTEvents] = [:]
    public var _observeId:String!
    
    deinit {
        self.removeObserving()
        self.removeObserver()
        self._events.removeAll(keepCapacity: false)
        self._observing.removeAll(keepCapacity: false)
    }
    
    public func sendEvent<U:Equatable>(eventKey:U, value: Any, forKeyPath:String? = nil) {
        let listeners:[TSTEventObject] = self.getEvents(eventKey)
        var removeEvents: [TSTEventObject] = []
        
        for i in 0..<listeners.count {
            let event = listeners[i]
            
            if let keyPath = forKeyPath, eventKeyPath = event.forKeyPath where keyPath != eventKeyPath {
                continue
            }
            
            if (event.eventKey as? U) == nil || (event.eventKey as? U) != eventKey {
                continue
            }
            
            event.handler?(value: value, forKeyPath: forKeyPath)
            
            if event.once {
                removeEvents.append(event)
            }
        }
        
        removeEvents.forEach { (event) -> () in
            self.removeObserver(observer: event.observer, eventKey: event.eventKey as? U, handler: event.handler)
        }
    }
    
    /**
    add event listener
    
    :param: eventName event name
    :param: once      once flag
    :param: listener  listener
    */
    public func addObserver<U:Equatable>(observer: NSObject, eventKey:U, forKeyPath: String? = nil, once:Bool = false, handler:TSTEventHandler) {
        let event = TSTEventObject(eventKey: eventKey, forKeyPath: forKeyPath, handler: handler, once: once, observer: observer)
        self._events.append(event)
    }
    
    public func addObserveTo(target: TSTEvents, eventKey:String, forKeyPath: String? = nil, once: Bool = false, handler: TSTEventHandler) {
        let id = uniqueId()
        
        if target._observeId == nil {
            target._observeId = id
        }
        
        if self._observing[id] == nil {
            self._observing[id] = target
        }
        
        target.addObserver(self, eventKey: eventKey, forKeyPath: forKeyPath, once: once, handler: handler)
    }
    
    public func removeObserving(target: TSTEvents? = nil) {
        if self._observing.isEmpty {
            return
        }
        
        var observing = self._observing
        if target != nil {
            if target!._observeId == nil {
                return
            }
            observing = [target!._observeId: target!]
        }
        
        for (_, object) in observing {
            object.removeObserver(observer: self)
            self._observing[object._observeId] = nil
        }
    }
    
    public func removeObserving(target: TSTEvents? = nil, handler: TSTEventHandler?) {
        if self._observing.isEmpty {
            return
        }
        
        var observing = self._observing
        if target != nil {
            if target!._observeId == nil {
                return
            }
            observing = [target!._observeId: target!]
        }
        
        for (_, object) in observing {
            object.removeObserver(observer: self, handler: handler)
        }
    }
    
    public func removeObserving<U:Equatable>(target: TSTEvents? = nil, eventKey:U) {
        if self._observing.isEmpty {
            return
        }
        
        var observing = self._observing
        if target != nil {
            if target!._observeId == nil {
                return
            }
            observing = [target!._observeId: target!]
        }
        
        for (observeId, object) in observing {
            
            object.removeObserver(observer: self, eventKey: eventKey)
            
            if object._events.isEmpty {
                self._observing[observeId] = nil
            }
        }
    }
    
    /**
    remove observing
    
    :param: target    observing object
    :param: eventName event name
    :param: callback  listener
    */
    public func removeObserving<U:Equatable>(target: TSTEvents? = nil, eventKey:U?, handler:TSTEventHandler?) {
        if self._observing.isEmpty {
            return
        }
        
        var observing = self._observing
        if target != nil {
            if target!._observeId == nil {
                return
            }
            observing = [target!._observeId: target!]
        }
        
        for (observeId, object) in observing {
            
            if eventKey == nil {
                object.removeObserver(observer: self, handler: handler)
            } else {
                object.removeObserver(observer: self, eventKey: eventKey!, handler: handler)
            }
            
            if object._events.isEmpty {
                self._observing[observeId] = nil
            }
        }
    }
    
    
    /**
    remove event by name and listener
    
    :param: eventName     event name
    :param: listenerOrNil listener
    */
    public func removeObserver<U:Equatable>(observer observerOrNil: NSObject? = nil, eventKey:U?, handler handlerOrNil:TSTEventHandler? = nil) {
        self._events = self._events.filter({ (event) -> Bool in
            if let handler = handlerOrNil where handler == event.handler {
                return false
            }
            
            if let observer = observerOrNil where observer == event.observer {
                return false
            }
            
            if let leftKey = eventKey, rightKey = event.eventKey as? U where leftKey == rightKey {
                return false
            }
            
            return true
        })
    }
    
    /**
    remove event by name and listener
    
    :param: eventName     event name
    :param: listenerOrNil listener
    */
    public func removeObserver(observer observerOrNil: NSObject? = nil, handler handlerOrNil:TSTEventHandler? = nil) {
        self._events = self._events.filter({ (event) -> Bool in
            if let handler = handlerOrNil where handler == event.handler {
                return false
            }
            
            if let observer = observerOrNil where observer == event.observer {
                return false
            }
            
            return true
        })
    }
    
    private func getEvents<U:Equatable>(eventKey:U) -> [TSTEventObject] {
        return self._events.filter({ (event:TSTEventObject) -> Bool in
            if let targetKey = event.eventKey as? U where targetKey == eventKey {
                return true
            } else {
                return false
            }
        })
    }
    
}

public struct TSTEventObject {
    var description:String {
        get {
            return "eventKey:\(eventKey), forKeyPath: \(forKeyPath), handler: \(handler), once: \(once)"
        }
    }
    
    var eventKey: Any?
    var forKeyPath: String?
    var handler: TSTEventHandler!
    var once:Bool = false
    
    weak var observer: NSObject!
}