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
            self.sendChangeEvent(self.hoge, forKeyPath: __FUNCTION__)
        }
    }
    
    var fuga:String = "fuga" {
        didSet {
            self.sendChangeEvent(self.fuga, forKeyPath: __FUNCTION__)
        }
    }
}

class SampleCollection:TSTCollectionBase {
}

class ModelManagerTests: XCTestCase {
    
    let eventemitter:TSTEvents = TSTEvents()
    let modelManager:TSTModelManager = TSTModelManager.sharedInstance
    let collection:TSTCollectionBase = TSTCollectionBase(key: "collection")
    let model:TSTModelBase = TSTModelBase(key: "model")
    let sampleModel:SampleModel = SampleModel(key: "sample")
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testCreateModel() {
        let model = modelManager.createModel(TSTModelBase.self, key: "customModel") as! TSTModelBase
        XCTAssertTrue(model.key as! String == "customModel", "")
    }
    
    func testSendEvent() {
        // This is an example of a functional test case.
        let expectation = expectationWithDescription(__FUNCTION__)
        
        model.addObserver(eventKey: "example", once: true) { (value:String, forKeyPath:String?) -> () in
            XCTAssertEqual(value, "args", "")
            expectation.fulfill()
        }
        
        model.sendEvent("example", value: "args")
        
        waitForExpectationsWithTimeout(2.0, handler: { (error) -> Void in
            XCTAssertNil(error, "error:\(error)")
        })
    }
    
    func testSendEventWithOnceOption() {
        // This is an example of a functional test case.
        let expectation = expectationWithDescription(__FUNCTION__)
        
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
        let expectation = expectationWithDescription(__FUNCTION__)
        
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
        let expectation = expectationWithDescription(__FUNCTION__)
        
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
        let expectation = expectationWithDescription(__FUNCTION__)
        let eventemitter2 = TSTEvents()
        
        eventemitter.addObserveTo(model, eventKey: "hogehoge", once: true) { (value:String, forKeyPath:String?) -> Void in
            XCTFail("this method should not be called")
        }
        
        eventemitter2.addObserveTo(model, eventKey: "hogehoge", once: true) { (value: String, forKeyPath:String?) -> () in
            XCTAssertEqual("hogehoge", value, "")
            expectation.fulfill()
        }
        
        eventemitter.removeObserving(model)
        
        model.sendEvent("hogehoge", value: "hogehoge")
        sampleModel.sendEvent("hogehoge", value: "hogehoge")
        
        waitForExpectationsWithTimeout(2.0, handler: { (error) -> Void in
            XCTAssertNil(error, "error:\(error)")
        })
    }
    
    func testSetAndGetModel() {
        modelManager.setModel(model)
        XCTAssertEqual(modelManager.getModel("model"), self.model, "")
    }
    
    func testRemoveModel() {
        modelManager.disposeModelByKey(model.key as! String)
        XCTAssertNil(modelManager.getModel("model"), "")
    }
    
    func testCollectionAdd() {
        let expectation = expectationWithDescription(__FUNCTION__)
        self.collection.addObserver(eventKey: collection.keyForAdd(), once: false) { (value:TSTModelBase, forKeyPath) -> () in
            XCTAssertEqual(value as! TSTModelBase, self.model, "")
            expectation.fulfill()
        }
        
        self.collection.addModel(model)
        
        waitForExpectationsWithTimeout(2.0, handler: { (error) -> Void in
            XCTAssertNil(error, "error:\(error)")
        })
    }
    
    func testCollectionRemove() {
        let expectation = expectationWithDescription(__FUNCTION__)
        self.collection.addObserver(eventKey: collection.keyForRemove(), once: false) { (model:TSTModelBase, forKeyPath) -> () in
            XCTAssertEqual(model.key as! String, "model", "")
            expectation.fulfill()
        }
        
        self.collection.addModel(model)
        self.collection.remove(model)
        
        waitForExpectationsWithTimeout(2.0, handler: { (error) -> Void in
            XCTAssertNil(error, "error:\(error)")
        })
    }
    
    func testCollectionUpdate() {
        let expectation = expectationWithDescription(__FUNCTION__)
        self.collection.addObserver(eventKey: collection.keyForChange(), once: false) { (model:TSTModelBase, forKeyPath) -> () in
            XCTAssertEqual(model.key as! String, "sample", "")
            expectation.fulfill()
        }
        
        self.collection.addModel(sampleModel)
        
        sampleModel.hoge = "fugafuga"
        
        waitForExpectationsWithTimeout(2.0, handler: { (error) -> Void in
            XCTAssertNil(error, "error:\(error)")
        })
    }
    
}
