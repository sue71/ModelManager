//
//  Model.swift
//  ModelManager
//
//  Created by Masaki Sueda on 2015/08/17.
//  Copyright (c) 2015年 Masaki Sueda. All rights reserved.
//

import Foundation

// Modelの基底クラス
public class TSTModelBase:TSTEvents {
    public var key:Any!
    
    public convenience init<U:Equatable>(key: U) {
        self.init()
        self.key = key
    }
    
    /**
    changeイベントを伝搬する
    :param: changed 変更されたパラメータ
    */
    public func sendChangeEvent<T>(changed: T, forKeyPath: String? = nil) {
        self.sendEvent(self.keyForChange(), value: changed, forKeyPath: forKeyPath)
        self.sendEvent(self.keyForChange(), value: changed as Any, forKeyPath: forKeyPath)
    }
    
    public func observeChangeEvent<T>(observer: NSObject? = nil, forKeyPath: String? = nil, once: Bool, handler: ((value: T, forKeyPath: String?) -> ())) {
        self.addObserver(observer: observer, eventKey: self.keyForChange(), forKeyPath: forKeyPath, once: once, handler: handler)
    }
    
    /**
    変更イベントのキーを返す
    */
    public func keyForChange() -> String {
        return TSTModelChangeKey
    }
}