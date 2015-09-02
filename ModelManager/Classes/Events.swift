//
//  Events.swift
//  ModelManager
//
//  Created by Masaki Sueda on 2015/08/17.
//  Copyright (c) 2015 Masaki Sueda. All rights reserved.
//

import Foundation

public class TSTEvents:NSObject {
    private var _events:[TSTEventObject] = []
    private var _observing:[String:TSTEvents] = [:]
    private var _observeId:String!
    
    deinit {
        self.removeObserving()
        self.removeObserver()
        self._events.removeAll(keepCapacity: false)
        self._observing.removeAll(keepCapacity: false)
    }
    
    public func sendEvent<U:Equatable, T>(eventKey:U, value: T, forKeyPath:String? = nil) {
        let listeners:[TSTEventObject] = self.getEvents(eventKey)
        var removeEvents: [TSTEventObject] = []
        
        for i in 0..<listeners.count {
            var event = listeners[i]
            if let handler = event.handler as? (value: T, forKeyPath: String?) -> Void {
                handler(value: value, forKeyPath: forKeyPath)
            }
            
            if forKeyPath != nil && forKeyPath! == event.forKeyPath {
                if let handler = event.handler as? (value: T, forKeyPath: String?) -> Void {
                    handler(value: value, forKeyPath: forKeyPath!)
                }
            }
            
            if event.once {
                removeEvents.append(event)
            }
        }
        
        var events = self._events
        
        self._events = self._events.filter({ (event:TSTEventObject) -> Bool in
            return removeEvents.filter({ (remove:TSTEventObject) -> Bool in
                var isEqualFunc:Bool = false
                if let leftHandler = event.handler as? (value:T, forKeyPath: String) -> (), rightHandler = remove.handler as? (value:T, forKeyPath: String) -> () where leftHandler == rightHandler {
                    isEqualFunc = true
                }
                if event.handler == nil && remove.handler == nil {
                    isEqualFunc = false
                }
                return event.eventKey as? U == remove.eventKey as? U &&
                    event.forKeyPath == remove.forKeyPath &&
                    event.observer == remove.observer &&
                    event.once == remove.once &&
                    isEqualFunc
            }).count == 0
        })
    }
    
    public func addObserveTo<T>(target: TSTEvents, eventKey:String, forKeyPath: String? = nil, once: Bool = false, handler: ((value: T, forKeyPath: String?) -> Void)) {
        let id = uniqueId()
        
        if target._observeId == nil {
            target._observeId = id
        }
        
        if self._observing[id] == nil {
            self._observing[id] = target
        }
        
        target.addObserver(observer: self, eventKey: eventKey, forKeyPath: forKeyPath, once: once, handler: handler)
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
        
        for (observeId, object) in observing {
            object.removeObserver(observer: self)
            self._observing[object._observeId] = nil
        }
    }
    
    public func removeObserving<T>(target: TSTEvents? = nil, handler: ((value:T, forKeyPath:String?) -> Void)?) {
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
    public func removeObserving<U:Equatable, T>(target: TSTEvents? = nil, eventKey:U?, handler: ((value: T, forKeyPath: String?) -> Void)?) {
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
    add event listener
    
    :param: eventName event name
    :param: once      once flag
    :param: listener  listener
    */
    public func addObserver<U:Equatable, T>(observer: NSObject? = nil, eventKey:U, forKeyPath: String? = nil, once:Bool = false, handler:((value:T, forKeyPath: String?) -> ())) {
        let event = TSTEventObject(eventKey: eventKey, forKeyPath: forKeyPath, handler: handler, once: once, observer: observer)
        self._events.append(event)
    }
    
    /**
    remove event by name and listener
    
    :param: eventName     event name
    :param: listenerOrNil listener
    */
    public func removeObserver<U:Equatable, T>(observer observerOrNil: NSObject? = nil, eventKey:U?, handler handlerOrNil:((value:T, forKeyPath: String?) -> ())?) {
        self._events = self._events.filter({ (event) -> Bool in
            if let handler = handlerOrNil {
                if let left = handlerOrNil, right = (event.handler as? ((value:T, forKeyPath:String?) -> Void)) where left == right {
                    return false
                }
            }
            
            if let observer: NSObject = observerOrNil {
                if observer == event.observer {
                    return false
                }
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
    public func removeObserver<T>(observer observerOrNil: NSObject? = nil, handler handlerOrNil:((value:T, forKeyPath: String?) -> ())?) {
        self._events = self._events.filter({ (event) -> Bool in
            if let handler = handlerOrNil {
                if let left = handlerOrNil, right = (event.handler as? ((value:T, forKeyPath:String?) -> Void)) where left == right {
                    return false
                }
            }
            
            if let observer: NSObject = observerOrNil {
                if observer == event.observer {
                    return false
                }
            }
            
            return true
        })
    }
    
    /**
    remove event by name and listener
    
    :param: eventName     event name
    :param: listenerOrNil listener
    */
    public func removeObserver<U:Equatable>(observer observerOrNil: NSObject? = nil, eventKey:U?) {
        self._events = self._events.filter({ (event) -> Bool in
            if let observer: NSObject = observerOrNil {
                if observer == event.observer {
                    return false
                }
            }
            
            if let leftKey = eventKey, rightKey = event.eventKey as? U where leftKey == rightKey {
                return false
            }
            
            return true
        })
    }
    
    /**
    remove event by observer
    */
    public func removeObserver(observer observerOrNil: NSObject? = nil) {
        self._events = self._events.filter({ (event) -> Bool in
            if let observer = observerOrNil, eventObserver = event.observer {
                if observer == eventObserver {
                    return false
                } else {
                    return true
                }
            }
            
            return false
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
    var eventKey: Any?
    var forKeyPath: String?
    var handler: Any?
    var once:Bool = false
    
    weak var observer: NSObject?
}