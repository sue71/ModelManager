//
//  Util.swift
//  ModelManager
//
//  Created by Masaki Sueda on 2015/08/17.
//  Copyright (c) 2015 Masaki Sueda. All rights reserved.
//

import Foundation

public func peekFunc<A,R>(f:A->R)->(fp:Int, ctx:Int) {
    typealias IntInt = (Int, Int)
    let (hi, lo) = unsafeBitCast(f, IntInt.self)
    let offset = sizeof(Int) == 8 ? 16 : 12
    let ptr  = UnsafePointer<Int>(bitPattern: lo+offset)
    return (ptr.memory, ptr.successor().memory)
}

public func == <A,R>(lhs:A->R,rhs:A->R)->Bool {
    let (tl, tr) = (peekFunc(lhs), peekFunc(rhs))
    return tl.0 == tr.0 && tl.1 == tr.1
}

public func classNameWithoutNamespace(object:AnyClass) -> String {
    let className = NSStringFromClass(object)
    if let range = className.rangeOfString(".") {
        return className.substringFromIndex(range.endIndex)
    }
    return className
}

public func uniqueId() -> String {
    return NSUUID().UUIDString
}
