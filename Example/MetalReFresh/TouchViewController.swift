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
    var timer: Timer!
    var toucheSet : Set<UITouch>!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?)
    {
       
        swipeMethod()
        toucheSet = touches
        
    }

    @objc private func update(tm: Timer)
    {
        timer.invalidate()
        pull.imageCount = TouchViewController.intCount
        pull.metalPosition(point: toucheSet.first!.location(in: self.view), view: self.view)
    
    }
    
    private func swipeMethod()
    {
        
        let directions: UISwipeGestureRecognizerDirection = .up
        
        let gesture = UISwipeGestureRecognizer(target: self,
                                               action:#selector(handleSwipe(sender:)))
        
        gesture.direction = directions
        gesture.numberOfTouchesRequired = 1
        self.view.addGestureRecognizer(gesture)
        
    }
    
    @objc func handleSwipe(sender: UISwipeGestureRecognizer)
    {
        
        timer = Timer.scheduledTimer(timeInterval: 1.0,
                                     target: self,
                                     selector: #selector(self.update),
                                     userInfo: nil, repeats: true)
        
    }
}
