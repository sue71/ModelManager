//
//  Collection.swift
//  ModelManager
//
//  Created by Masaki Sueda on 2015/08/17.
//  Copyright (c) 2015 Masaki Sueda. All rights reserved.
//

import Foundation

public class TSTCollectionBase:TSTModelBase {
    deinit {
        for model in models {
            model.removeObserver(observer: self)
        }
        self.models.removeAll(keepCapacity: false)
    }
    
    public var models:[TSTModelBase] = []
    
    /**
    Modelをコレクションに追加し、
    追加されたModelを監視する
    addイベントが伝搬する
    
    :param: model Model
    */
    public func addModel(model: TSTModelBase) {
        model.addObserver(self, eventKey: model.keyForChange(), forKeyPath: nil, once: false) {[weak self] (value, forKeyPath) -> Void in
            if let blockSelf = self {
                blockSelf.sendEvent(blockSelf.keyForChange(), value: model)
            }
        }
        self.models.append(model)
        self.sendEvent(self.keyForAdd(), value: model)
    }
    
    /**
    Modelを複数追加する
    updateイベントが伝搬する
    
    :param: models Modelの配列
    */
    public func addModels(models: [TSTModelBase]) {
        for model in models {
            self.addModel(model)
        }
    }
    
    /**
    Modelを取り除く
    
    :param: model Model
    */
    public func remove(model:TSTModelBase) {
        model.removeObserver(observer: self)
        for var i = 0; i < self.models.count; i++ {
            if model == self.models[i] {
                self.models.removeAtIndex(i)
                
                self.sendEvent(self.keyForRemove(), value: model)
                break
            }
        }
    }
    
    /**
    追加イベントのキーを返す
    
    :returns:
    */
    public func keyForAdd() -> String {
        return TSTCollectionAddKey
    }
    
    /**
    更新イベントのキーを返す
    
    :returns:
    */
    public override func keyForChange() -> String {
        return TSTCollectionChangeKey
    }
    
    /**
    削除イベントのキーを返す
    
    :returns:
    */
    public func keyForRemove() -> String {
        return TSTCollectionRemoveKey
    }
}