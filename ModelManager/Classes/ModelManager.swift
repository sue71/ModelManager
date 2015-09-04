//
//  ModelManager.swift
//  ModelManager
//
//  Created by Masaki Sueda on 2015/07/23.
//  Copyright (c) 2015 Masaki Sueda. All rights reserved.
//

import Foundation

public let TSTModelChangeKey = "TSTModelChangeKey"
public let TSTCollectionChangeKey = "TSTCollectionChangeKey"
public let TSTCollectionAddKey = "TSTCollectionAddKey"
public let TSTCollectionRemoveKey = "TSTCollectionRemoveKey"

// Utility

// TSTModelManager
// Modelの参照を管理する
public class TSTModelManager:NSObject {
    public static var sharedInstance : TSTModelManager = TSTModelManager()
    
    private var models:[Model] = []
    
    public func createModel<U: Equatable>(clazz: NSObject.Type, key: U) -> TSTEvents? {
        if let model = clazz.new() as? TSTModelBase {
            model.key = key
            self.models.append(Model(key: key, object: model))
            return model
        }
        return nil
    }
    
    /**
    Modelを保持する
    
    :param: name ModelのIDになる文字列
    :param: model Modelのインスタンス
    */
    public func setModel(model: TSTModelBase) {
        self.models.append(Model(key: model.key, object: model))
    }
    
    /**
    Modelを取得する
    
    :param: name ModelのID
    
    :returns: Modelが存在しない場合nilを返す
    */
    public func getModel<U:Equatable>(key:U) -> TSTModelBase? {
        var models = self.models.filter { (model) -> Bool in
            if let targetKey = model.key as? U where targetKey == key {
                return true
            }
            return false
        }
        var model:TSTModelBase? = models.count > 0 ? models[0].object : nil
        
        return model
    }
    
    /**
    keyを指定してModelを破棄
    
    :param: key
    */
    public func disposeModelByKey<U:Equatable>(key:U) {
        self.models = self.models.filter({ (model) -> Bool in
            if let targetKey = model.key as? U where targetKey == key {
                
                model.object.removeObserving()
                model.object.removeObserver()
                
                return false
            }
            return true
        })
    }
    
    private struct Model {
        var key:Any
        var object:TSTModelBase
    }
}

