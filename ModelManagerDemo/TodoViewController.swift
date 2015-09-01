//  TodoViewController.swift
//  ModelManager
//
//  Created by Masaki Sueda on 2015/07/29.
//  Copyright (c) 2015年 Masaki Sueda. All rights reserved.
//

import Foundation
import UIKit
import ModelManager

class TodoCollection: TSTCollectionBase, UITableViewDataSource {
    
    deinit {
        NSLog("[deinit][TodoCollection]")
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.models.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell") as! TodoView
        cell.model = self.models[indexPath.item] as? TodoModel
        
        return cell
    }
}

class TodoModel: TSTModelBase {
    deinit {
        NSLog("[deinit][TodoModel]")
    }
    
    var title:String = "" {
        didSet {
            self.sendChangeEvent(self.title)
        }
    }
    
    var done:Bool = false {
        didSet {
            self.sendChangeEvent(self.done)
        }
    }
}

class TodoView: UITableViewCell {
    var model:TodoModel? {
        willSet {
            self.model?.removeObserver(observer: self)
        }
        didSet {
            self.model!.addObserver(observer:self, eventName: self.model!.keyForChange(), once: false) {[weak self] (args) -> Void in
                self?.updateView()
            }
            self.updateView()
        }
    }
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var doneSwitch: UISwitch!
    
    deinit {
        self.model?.removeObserver(observer: self)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.doneSwitch.addTarget(self, action: "didChangeSwitch:", forControlEvents: UIControlEvents.ValueChanged)
    }
    
    func didChangeSwitch(sender: AnyObject) {
        self.model!.done = self.doneSwitch.on
    }
    
    func updateView() {
        self.title.text = self.model!.title
        self.doneSwitch.setOn(self.model!.done, animated: true)
    }
    
}

class TodoViewController: UIViewController, UITableViewDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    var todoCollection:TodoCollection! = TodoCollection(modelId: "todoCollection")
    @IBOutlet weak var newLabel: UILabel!
    @IBOutlet weak var textField: UITextField!
    deinit {
        NSLog("[deinit][TodoViewController]")
        self.todoCollection.removeObserver(observer:self)
        TSTModelManager.sharedInstance.disposeModel(self.todoCollection)
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        TSTModelManager.sharedInstance.setModel(self.todoCollection)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.delegate = self
        self.tableView.dataSource = self.todoCollection
        
        self.todoCollection.addObserver(observer: self, eventName: self.todoCollection.keyForAdd(), once: false) {[weak self] (args) -> Void in
            self?.tableView.reloadData()
        }
        
        self.textField.delegate = self
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.textField.endEditing(true)
        var model = TodoModel(modelId: "model")
        model.title = textField.text
        
        self.todoCollection.addModel(model)
        self.textField.text = nil
        return true
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 50
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
    }
}

class DoneLabel: UILabel {
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        let model:TSTCollectionBase? = TSTModelManager.sharedInstance.getModel("todoCollection") as? TSTCollectionBase
        if let collection = model {
            collection.addObserver(observer: self, eventName: collection.keyForChange(), forKeyPath: nil, once: false, listener: {[weak self] (args, keyPath) -> () in
                let count = collection.models.filter({ (model:TSTModelBase) -> Bool in
                    let model = model as! TodoModel
                    return model.done
                }).count.description
                self?.text = "done:\(count)"
                })
        }
    }
}
