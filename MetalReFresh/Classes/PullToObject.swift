//
//  PullToObject.swift
//  sampleAnmation
//
//  Created by nagatadaisuke on 2017/09/27.
//  Copyright © 2017年 永田大祐. All rights reserved.
//


import UIKit
import Foundation
import MetalKit

public class PullToObject:NSObject{
    
    open var metalView: MTKView!
    var aAPLRenderer = AAPLRenderer()
    var timer: Timer!
    var viewSet : UITableView!
    var alphaView = UIView()
    open var imageCount = 0
    
    public func timerSet(view:UITableView?)
    {
        guard view != nil else {
            
            return
            
        }
        
        self.viewSet = view
        timer = Timer.scheduledTimer(timeInterval: 5.0,
                                     target: self,
                                     selector: #selector(self.update),
                                     userInfo: nil, repeats: true)
        
        timer.fire()
    }
    
    public func invalidate()
    {
        if self.metalView != nil {
            
        self.metalView.removeFromSuperview()
        self.metalView = nil
        timer.invalidate()
        
        }
    }
    
    @objc private func update(tm: Timer)
    {
  
        if self.metalView == nil {
            
            self.aAPLRenderer.screenAnimation = 11
            self.setupView()
           
        }else{
            
            self.metalView.removeFromSuperview()
            self.metalView = nil
            
            timer.invalidate()
            alphaView.alpha = 0
            
        }
        
    }
    
    private func setupView()
    {
        
        if self.metalView == nil {
            
            self.alphaView.frame = CGRect(x:0,y:-UIScreen.main.bounds.size.height/4,
                                          width:UIScreen.main.bounds.size.width,
                                          height:UIScreen.main.bounds.size.height)
            
            self.alphaView.backgroundColor = UIColor.black
            self.alphaView.alpha = 0.3
            self.viewSet.addSubview(self.alphaView)
        
            self.metalView = MTKView()
            self.viewSet.addSubview(metalView)
            self.metalView.device = MTLCreateSystemDefaultDevice()
            self.metalView.colorPixelFormat = MTLPixelFormat.bgra8Unorm
            self.metalView.clearColor =  MTLClearColorMake(0, 0, 0, 1)
            self.metalView.isUserInteractionEnabled = true
            self.metalView.frame = self.viewSet.frame
            
            self.aAPLRenderer.imageCount = imageCount
            self.aAPLRenderer.instanceWithView(view: ViewAnimation.viewAnimation.animateImage(target: self.metalView) as! MTKView)
            
        }
    }
}
