//
//  ModelManagerTests.swift
//  ModelManagerTests
//
//  Created by Masaki Sueda on 2015/07/23.
//  Copyright (c) 2015年 Masaki Sueda. All rights reserved.
//

import UIKit
import XCTest
import ModelManager

class SampleModel:TSTModelBase {
    var hoge:String = "hoge" {
        didSet {
            self.sendChangeEvent(self.hoge)
        }
    }
    var fuga:String = "fuga" {
        didSet {
            self.sendChangeEvent(self.fuga)
        }
    }
}

class SampleCollection:TSTCollectionBase {
}

class ModelManagerTests: XCTestCase {
    
    let eventemitter:TSTEvents = TSTEvents()
    let modelManager:TSTModelManager = TSTModelManager.sharedInstance
    let collection:TSTCollectionBase = TSTCollectionBase(modelId: "todoCollection")
    let model:TSTModelBase = TSTModelBase(modelId: "model")
    let sampleModel:SampleModel = SampleModel(modelId: "sample")
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testSendEvent() {
        // This is an example of a functional test case.
        let expectation = expectationWithDescription("testSendEvent")
        
        model.addObserver(eventName: "example", once: true) { (args, forKey) -> () in
            if let strs:[String] = args as? [String] {
                XCTAssertEqual("args", strs[0], "")
                XCTAssertEqual("test", strs[1], "")
                expectation.fulfill()
            }
        }
        
        model.sendEvent("example", args: "args", "test")
        
        waitForExpectationsWithTimeout(2.0, handler: { (error) -> Void in
            XCTAssertNil(error, "error:\(error)")
        })
    }
    
    func testSendEventWithOnceOption() {
        // This is an example of a functional test case.
        let expectation = expectationWithDescription("testSendEventWithOnceOption")
        
        model.addObserver(eventName: "example", once: true) { (args, forKey) -> () in
            if let strs:[String] = args as? [String] {
                XCTAssertEqual("args", strs[0], "")
                XCTAssertEqual("test", strs[1], "")
                
                expectation.fulfill()
            }
        }
        
        model.sendEvent("example", args: "args", "test")
        model.sendEvent("example", args: "args", "test")
        
        waitForExpectationsWithTimeout(2.0, handler: { (error) -> Void in
            XCTAssertNil(error, "error:\(error)")
        })
    }
    
    func testSendChangeEvent() {
        // This is an example of a functional test case.
        let expectation = expectationWithDescription("testSendChangeEvent")
        
        sampleModel.addObserver(eventName: sampleModel.keyForChange(), once: true) { (args, forKey) -> () in
            if let strs:[String] = args as? [String] {
                XCTAssertEqual("fugafuga", strs[0], "")
                expectation.fulfill()
            }
        }
        
        sampleModel.fuga = "fugafuga"
        
        waitForExpectationsWithTimeout(2.0, handler: { (error) -> Void in
            XCTAssertNil(error, "error:\(error)")
        })
    }
    
    func testObserveEvent() {
        let expectation = expectationWithDescription("testObserveEvent")
        eventemitter.addObserveTo(model, eventName: "hogehoge", once: false) { (args, forKey) -> () in
            XCTAssertEqual("hogehoge", args[0] as! String, "")
            expectation.fulfill()
        }
        
        model.sendEvent("hogehoge", args: "hogehoge")
        
        waitForExpectationsWithTimeout(2.0, handler: { (error) -> Void in
            XCTAssertNil(error, "error:\(error)")
        })
    }
    
    func testRemoveObserving() {
        let expectation = expectationWithDescription("testSendChangeEvent")
        let eventemitter2 = TSTEvents()
        
        eventemitter.addObserveTo(model, eventName: "hogehoge", once: true) { (args, forKey) -> () in
            XCTFail("this method should not be called")
        }
        
        eventemitter.addObserveTo(sampleModel, eventName: "hogehoge", once: true) { (args, forKey) -> () in
            XCTAssertEqual("hogehoge", args[0] as! String, "")
        }
        
        eventemitter2.addObserveTo(model, eventName: "hogehoge", once: true) { (args, forKey) -> () in
            XCTAssertEqual("hogehoge", args[0] as! String, "")
            expectation.fulfill()
        }
        
        eventemitter.removeObserving(target: model)
        
        model.sendEvent("hogehoge", args: "hogehoge")
        sampleModel.sendEvent("hogehoge", args: "hogehoge")
        
        waitForExpectationsWithTimeout(2.0, handler: { (error) -> Void in
            XCTAssertNil(error, "error:\(error)")
        })
    }
    
    func testSetAndGetModel() {
        modelManager.setModel(model)
        XCTAssertEqual(modelManager.getModel("model")!.modelId, "model", "")
    }
    
    func testCollectionAdd() {
        let expectation = expectationWithDescription("testCollectionAdd")
        self.collection.addObserver(eventName: collection.keyForAdd(), once: false) { (args, forKey) -> () in
            if let model = args[0] as? TSTModelBase {
                XCTAssertEqual(model.modelId, "model", "")
                
                expectation.fulfill()
            }
        }
        
        self.collection.addModel(model)
        
        waitForExpectationsWithTimeout(2.0, handler: { (error) -> Void in
            XCTAssertNil(error, "error:\(error)")
        })
    }
    
    func testCollectionRemove() {
        let expectation = expectationWithDescription("testCollectionRemove")
        self.collection.addObserver(eventName: collection.keyForRemove(), once: false) { (args, forKey) -> () in
            if let model = args[0] as? TSTModelBase {
                XCTAssertEqual(model.modelId, "model", "")
                
                expectation.fulfill()
            }
        }
        
        self.collection.addModel(model)
        self.collection.remove(model)
        
        waitForExpectationsWithTimeout(2.0, handler: { (error) -> Void in
            XCTAssertNil(error, "error:\(error)")
        })
    }
    
    func testCollectionUpdate() {
        let expectation = expectationWithDescription("testCollectionUpdate")
        self.collection.addObserver(eventName: collection.keyForChange(), once: false) { (args, forKey) -> () in
            if let model = args[0] as? TSTModelBase {
                XCTAssertEqual(model.modelId, "sample", "")
                
                expectation.fulfill()
            }
        }
        
        self.collection.addModel(sampleModel)
        
        sampleModel.hoge = "fugafuga"
        
        waitForExpectationsWithTimeout(2.0, handler: { (error) -> Void in
            XCTAssertNil(error, "error:\(error)")
        })
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock() {
            // Put the code you want to measure the time of here.
        }
    }
    
}
