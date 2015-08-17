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
private func peekFunc<A,R>(f:A->R)->(fp:Int, ctx:Int) {
    typealias IntInt = (Int, Int)
    let (hi, lo) = unsafeBitCast(f, IntInt.self)
    let offset = sizeof(Int) == 8 ? 16 : 12
    let ptr  = UnsafePointer<Int>(bitPattern: lo+offset)
    return (ptr.memory, ptr.successor().memory)
}

private func == <A,R>(lhs:A->R,rhs:A->R)->Bool {
    let (tl, tr) = (peekFunc(lhs), peekFunc(rhs))
    return tl.0 == tr.0 && tl.1 == tr.1
}
    
private func classNameWithoutNamespace(object:AnyClass) -> String {
    let className = NSStringFromClass(object)
    if let range = className.rangeOfString(".") {
        return className.substringFromIndex(range.endIndex)
    }
    return className
}

private func uniqueId() -> String {
    return NSUUID().UUIDString
}

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