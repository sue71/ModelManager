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
    public func sendChangeEvent<T>(changed: T, forKeyPath: String) {
        self.sendEvent(self.keyForChange(), value: changed)
        self.sendEvent(self.keyForChange(), value: changed as Any)
    }
    
    /**
    変更イベントのキーを返す
    */
    public func keyForChange() -> String {
        return TSTModelChangeKey
    }
}