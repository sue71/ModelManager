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

public typealias TSTEventHandler = (args: [NSObject]) -> ()

// Utility

// TSTModelManager
// Modelの参照を管理する
public class TSTModelManager:NSObject {
    public static var sharedInstance : TSTModelManager = TSTModelManager()
    
    var models:[String:TSTModelBase] = [:]

    /**
    Modelを保持する
    
    :param: name ModelのIDになる文字列
    :param: model Modelのインスタンス
    */
    public func setModel(model:TSTModelBase) {
        self.models[model.modelId] = model
    }
    
    /**
    Modelを取得する
    
    :param: name ModelのID
    
    :returns: Modelが存在しない場合nilを返す
    */
    public func getModel(name:String) -> TSTModelBase? {
        return self.models[name]
    }
    
    /**
    Modelを破棄する
    
    :param: model 破棄するModel
    */
    public func disposeModel(model:TSTModelBase) {
        self.models.removeValueForKey(model.modelId)
    }
    
    /**
    IDを指定してModelを破棄
    
    :param: name ModelのID
    */
    public func disposeModelByName(name:String) {
        self.models.removeValueForKey(name)
    }
}
