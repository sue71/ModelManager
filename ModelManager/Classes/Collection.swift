//
//  Collection.swift
//  ModelManager
//
//  Created by Masaki Sueda on 2015/08/17.
//  Copyright (c) 2015 Masaki Sueda. All rights reserved.
//

import Foundation

public class TSTCollectionBase:TSTEvents {
    public var models:[TSTModelBase] = []
    
    /**
    Modelをコレクションに追加し、
    追加されたModelを監視する
    addイベントが伝搬する
    
    :param: model Model
    */
    public func addModel(model: TSTModelBase) {
        model.addObserver(observer: self, eventName: model.keyForChange(), once: false) {[weak self] (args) -> () in
            if let blockSelf = self {
                blockSelf.sendEvent(blockSelf.keyForChange(), args: model)
            }
        }
        self.models.append(model)
        self.sendEvent(self.keyForAdd(), args: model)
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
        self.removeObserving(target: model)
        for var i = 0; i < self.models.count; i++ {
            if model == self.models[i] {
                self.models.removeAtIndex(i)
                self.sendEvent(self.keyForRemove(), args: model)
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
    public func keyForChange() -> String {
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