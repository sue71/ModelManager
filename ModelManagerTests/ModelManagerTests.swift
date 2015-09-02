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
        
        model.addObserver(eventKey: "example", once: true) { (value:String, forKeyPath:String?) -> () in
            XCTAssertEqual("args", value, "")
            expectation.fulfill()
        }
        
        model.sendEvent("example", value: "args")
        
        waitForExpectationsWithTimeout(2.0, handler: { (error) -> Void in
            XCTAssertNil(error, "error:\(error)")
        })
    }
    
    func testSendEventWithOnceOption() {
        // This is an example of a functional test case.
        let expectation = expectationWithDescription("testSendEventWithOnceOption")
        
        model.addObserver(eventKey: "example", once: true) { (str:String, forKeyPath:String?) -> () in
            XCTAssertEqual("args", str, "")
            expectation.fulfill()
        }
        
        model.sendEvent("example", value: "args")
        
        waitForExpectationsWithTimeout(2.0, handler: { (error) -> Void in
            XCTAssertNil(error, "error:\(error)")
        })
    }
    
    func testSendChangeEvent() {
        // This is an example of a functional test case.
        let expectation = expectationWithDescription("testSendChangeEvent")
        
        sampleModel.addObserver(eventKey: sampleModel.keyForChange(), once: true) { (str:String, forKeyPath:String?) -> () in
            XCTAssertEqual("fugafuga", str, "")
            expectation.fulfill()
        }
        
        sampleModel.fuga = "fugafuga"
        
        waitForExpectationsWithTimeout(2.0, handler: { (error) -> Void in
            XCTAssertNil(error, "error:\(error)")
        })
    }
    
    func testObserveEvent() {
        let expectation = expectationWithDescription("testObserveEvent")
        
        eventemitter.addObserveTo(model, eventKey: "hogehoge", once: false) { (arg:String, forKeyPath:String?) -> () in
            XCTAssertEqual("hogehoge", arg, "")
            expectation.fulfill()
        }
        
        model.sendEvent("hogehoge", value: "hogehoge")
        
        waitForExpectationsWithTimeout(2.0, handler: { (error) -> Void in
            XCTAssertNil(error, "error:\(error)")
        })
    }
    
    func testRemoveObserving() {
        let expectation = expectationWithDescription("testSendChangeEvent")
        let eventemitter2 = TSTEvents()
        
        eventemitter.addObserveTo(model, eventKey: "hogehoge", once: true) { (value:String, forKeyPath:String?) -> Void in
            XCTFail("this method should not be called")
        }
        
        eventemitter2.addObserveTo(model, eventKey: "hogehoge", once: true) { (value: String, forKeyPath:String?) -> () in
            XCTAssertEqual("hogehoge", value, "")
            expectation.fulfill()
        }
        
        eventemitter.removeObserving(target: model)
        
        model.sendEvent("hogehoge", value: "hogehoge")
        sampleModel.sendEvent("hogehoge", value: "hogehoge")
        
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
        self.collection.addObserver(eventKey: collection.keyForAdd(), once: false) { (value:TSTModelBase, forKeyPath) -> () in
            XCTAssertEqual(value.modelId, "model", "")
            expectation.fulfill()
        }
        
        self.collection.addModel(model)
        
        waitForExpectationsWithTimeout(2.0, handler: { (error) -> Void in
            XCTAssertNil(error, "error:\(error)")
        })
    }
    
    func testCollectionRemove() {
        let expectation = expectationWithDescription("testCollectionRemove")
        self.collection.addObserver(eventKey: collection.keyForRemove(), once: false) { (model:TSTModelBase, forKeyPath) -> () in
            XCTAssertEqual(model.modelId, "model", "")
            expectation.fulfill()
        }
        
        self.collection.addModel(model)
        self.collection.remove(model)
        
        waitForExpectationsWithTimeout(2.0, handler: { (error) -> Void in
            XCTAssertNil(error, "error:\(error)")
        })
    }
    
    func testCollectionUpdate() {
        let expectation = expectationWithDescription("testCollectionUpdate")
        self.collection.addObserver(eventKey: collection.keyForChange(), once: false) { (model:TSTModelBase, forKeyPath) -> () in
            XCTAssertEqual(model.modelId, "sample", "")
            expectation.fulfill()
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
