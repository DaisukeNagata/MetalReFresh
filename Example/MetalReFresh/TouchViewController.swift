//
//  TouchViewController.swift
//  MetalReFresh_Example
//
//  Created by 永田大祐 on 2017/11/29.
//  Copyright © 2017年 CocoaPods. All rights reserved.
//

import UIKit
import MetalReFresh

class TouchViewController: UIViewController {

    static var intCount = Int()
    var pull = PullToObject()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
       
        pull.imageCount = TouchViewController.intCount
        pull.metalPosition(point: touches.first!.location(in: self.view), view: self.view)
        
    }

}
