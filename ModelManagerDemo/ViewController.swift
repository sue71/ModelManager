//
//  ViewController.swift
//  ModelManagerDemo
//
//  Created by Masaki Sueda on 2015/07/29.
//  Copyright (c) 2015年 Masaki Sueda. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    var centerViewController:UIViewController!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let navi = UINavigationController(navigationBarClass: nil, toolbarClass: nil)
        
        var className = NSStringFromClass(TodoViewController).componentsSeparatedByString(".").last! as String
        let storyBoard = UIStoryboard(name: className, bundle: nil)
        let viewController = storyBoard.instantiateInitialViewController() as! UIViewController
        
        navi.pushViewController(viewController, animated: false)
        self.centerViewController = navi
        
        self.view.addSubview(self.centerViewController.view)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

