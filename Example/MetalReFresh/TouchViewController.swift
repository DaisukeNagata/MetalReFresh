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

        swipeMethod()
        
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
       pull.imageCount = TouchViewController.intCount
        // タップした座標を取得する
        pull.metalPosition(point: touches.first!.location(in: self.view), view: self.view)
    }
    
    private func swipeMethod()
    {
        
        let directions: UISwipeGestureRecognizerDirection = .right
        
        let gesture = UISwipeGestureRecognizer(target: self,
                                               action:#selector(handleSwipe(sender:)))
        
        gesture.direction = directions
        gesture.numberOfTouchesRequired = 2
        self.view.addGestureRecognizer(gesture)
        
    }
    
    @objc func handleSwipe(sender: UISwipeGestureRecognizer)
    {
        
        let vc = ViewController()
        self.present(vc, animated: true)
        
    }
}
