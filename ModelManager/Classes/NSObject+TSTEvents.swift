//
//  NSObject+TSTEvents.swift
//  ModelManager
//
//  Created by Masaki Sueda on 2015/09/03.
//  Copyright (c) 2015年 Masaki Sueda. All rights reserved.
//

import Foundation

private var TSTEventsKey = 0
extension NSObject {
    
    private var _event:TSTEvents? {
        get {
            return objc_getAssociatedObject(self, &TSTEventsKey) as? TSTEvents
        }
        set {
            objc_setAssociatedObject(self, &TSTEventsKey, newValue, objc_AssociationPolicy(OBJC_ASSOCIATION_RETAIN_NONATOMIC))
        }
    }
    
    public func tst_sendEvent<U:Equatable, T>(eventKey:U, value:T, forKeyPath keyPath: String? = nil) {
        if self._event == nil {
            self._event = TSTEvents()
        }
        self._event!.sendEvent(eventKey, value: value, forKeyPath: keyPath)
    }
    
    public func tst_addObserver<U:Equatable, T>(observer: NSObject, eventKey:U, forKeyPath keyPath: String? = nil, once:Bool = false, handler: ((value:T, forKeyPath:String?) -> Void)) {
        if self._event == nil {
            self._event = TSTEvents()
        }
        self._event!.addObserver(observer: observer, eventKey: eventKey, forKeyPath: keyPath, once: once, handler: handler)
    }
    
}