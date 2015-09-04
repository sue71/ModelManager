//
//  CollectionTest.swift
//  Collection
//
//  Created by Masaki Sueda on 2015/07/23.
//  Copyright (c) 2015年 Masaki Sueda. All rights reserved.
//

import Foundation
import ModelManager
import XCTest


class CollectionTests: XCTestCase {
    
    let modelManager:TSTModelManager = TSTModelManager.sharedInstance
    let collection:TSTCollectionBase = TSTCollectionBase()
    let model:TSTModelBase = TSTModelBase()
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock() {
            // Put the code you want to measure the time of here.
        }
    }
    
}