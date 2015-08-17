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
    
    public var modelId:String!
    
    public init(modelId: String) {
        super.init()
        self.modelId = modelId
    }
    
    /**
    changeイベントを伝搬する
    
    :param: changed 変更されたパラメータ
    */
    public func sendChangeEvent(changed:NSObject) {
        self.sendEvent(self.keyForChange(), args: changed)
    }
    
    /**
    変更イベントを監視する
    
    :param: observer 監視者
    :param: callback イベントハンドラ
    */
    public func observeChangeEvent(observer:NSObject, once:Bool = false, callback: TSTEventHandler) {
        self.addObserver(observer: observer, eventName: self.keyForChange(), once: once, listener: callback)
    }
    
    /**
    イベント監視を破棄する
    
    :param: observer 監視者
    */
    public func removeObserve(observer:NSObject, eventName:String, callback:TSTEventHandler) {
        self.removeObserver(observer: observer, eventName: eventName, listener: callback)
    }
    
    /**
    変更イベントのキーを返す
    */
    public func keyForChange() -> String {
        return TSTModelChangeKey
    }
}
