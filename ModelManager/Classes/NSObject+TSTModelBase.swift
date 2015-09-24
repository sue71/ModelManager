//
//  NSObject+TSTModelBaseKey.swift
//  ModelManager
//
//  Created by Masaki Sueda on 2015/09/03.
//  Copyright (c) 2015 Masaki Sueda. All rights reserved.
//

import Foundation

private var TSTModelBaseKey = 0
public extension NSObject {
    
    public var tst_model:TSTModelBase? {
        get {
            return objc_getAssociatedObject(self, &TSTModelBaseKey) as? TSTModelBase
        }
        set {
            objc_setAssociatedObject(self, &TSTModelBaseKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    public func tst_postChange<T>(value:T, forKeyPath keyPath: String? = nil) {
        if self.tst_model == nil {
            self.tst_model = TSTModelBase()
        }
        self.tst_model?.sendChangeEvent(value, forKeyPath: keyPath)
    }
    
    public func tst_observeChange<T>(observer: NSObject, forKeyPath keyPath: String? = nil, handler: ((value:T, forKeyPath:String?) -> Void)) {
        if self.tst_model == nil {
            self.tst_model = TSTModelBase()
        }
        self.tst_model?.observeChangeEvent(observer, forKeyPath: keyPath, once: false, handler: handler)
    }
    
    public func tst_observeTo<T>(target: NSObject, forKeyPath keyPath: String? = nil, once: Bool = false, handler: ((value: T, forKeyPath: String?) -> Void)) {
        if self.tst_model == nil {
            self.tst_model = TSTModelBase()
        }
        
        let id = uniqueId()
        if target.tst_model!._observeId == nil {
            target.tst_model!._observeId = id
        }
        
        if self.tst_model!._observing[id] == nil {
            self.tst_model!._observing[id] = target.tst_model
        }
        
        target.tst_observeChange(self, forKeyPath: keyPath, handler: handler)
    }
    
    public func tst_removeObserving() {
        if self.tst_model == nil {
            self.tst_model = TSTModelBase()
        }
        
        if self.tst_model!._observing.isEmpty {
            return
        }
        
        self.tst_model!.removeObserving()
    }
    
    public func tst_removeObserver() {
        if self.tst_model == nil {
            self.tst_model = TSTModelBase()
        }
        self.tst_model?.removeObserver()
    }
    
}