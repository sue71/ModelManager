//
//  Events.swift
//  ModelManager
//
//  Created by Masaki Sueda on 2015/08/17.
//  Copyright (c) 2015 Masaki Sueda. All rights reserved.
//

import Foundation

public struct TSTEventObject {
    var listener:TSTEventHandler
    var once:Bool = false
    var observer: NSObject?
}

public class TSTEvents:NSObject {
    private var _events:[String: [TSTEventObject]] = [:]
    private var _observing:[String: TSTEvents] = [:]
    private var _observeId:String!
    
    deinit {
        self._events.removeAll(keepCapacity: false)
        self._observing.removeAll(keepCapacity: false)
    }
    
    public func sendEvent(eventName:String, args: NSObject...) {
        let listeners:[TSTEventObject] = self.getListeners(eventName)
        var count:Int = 0
        for var i = 0; i < listeners.count; i++ {
            var event = listeners[count]
            event.listener(args: args)
            if event.once {
                self._events[eventName]?.removeAtIndex(count)
                continue
            }
            count++
        }
    }
    
    public func addObserveTo(target: TSTEvents, eventName:String, once: Bool = false, callback: TSTEventHandler) {
        let id = uniqueId()
        
        if target._observeId == nil {
            target._observeId = id
        }
        
        if self._observing[id] == nil {
            self._observing[id] = target
        }
        
        target.addObserver(observer: self, eventName: eventName, once: once, listener: callback)
    }
    
    /**
    remove observing
    
    :param: target    observing object
    :param: eventName event name
    :param: callback  listener
    */
    public func removeObserving(target: TSTEvents? = nil, eventName:String? = nil, callback: TSTEventHandler? = nil) {
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
            
            if eventName == nil {
                for (eventName, event) in object._events {
                    object.removeObserver(observer: self, eventName: eventName)
                }
            } else {
                object.removeObserver(observer: self, eventName: eventName!, listener: callback)
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
    public func addObserver(observer: NSObject? = nil, eventName:String, once:Bool = false, listener:TSTEventHandler) {
        if self._events[eventName] == nil {
            self._events[eventName] = []
        }
        
        let event = TSTEventObject(listener: listener, once: once, observer: observer)
        self._events[eventName]?.append(event)
    }
    
    /**
    remove event by name and listener
    
    :param: eventName     event name
    :param: listenerOrNil listener
    */
    public func removeObserver(observer observerOrNil: NSObject? = nil, eventName:String? = nil, listener listenerOrNil:TSTEventHandler? = nil) {
        var removeIndex:[Int] = []
        var events:[String] = []
        if eventName == nil {
            events = Array(self._events.keys)
        } else {
            events = [eventName!]
        }
    
        for eventName in events {
            for var i = 0; i < self._events[eventName]?.count; i++ {
                var listeners = self.getListeners(eventName)
                var event = listeners[i]
                if let listener = listenerOrNil {
                    if listener == event.listener {
                        self._events[eventName]?.removeAtIndex(i)
                        continue
                    }
                }
                
                if let observer: NSObject = observerOrNil {
                    if observer == event.observer {
                        self._events[eventName]?.removeAtIndex(i)
                    }
                    continue
                }
                
                self._events[eventName]?.removeAtIndex(i)
            }
        
        }
        
    }
    
    private func getListeners(eventName:String) -> [TSTEventObject] {
        return self._events[eventName] ?? []
    }
    
}