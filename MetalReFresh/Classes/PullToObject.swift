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
    
    open var imageCount = 0
    open var metalView: MTKView!
    
    var alphaView = MTKView()
    var aAPLRenderer = AAPLRenderer()
    var tessellationPipeline =  AAPLTessellationPipeline()
    
    var timer: Timer!
    var updateAnimation: Timer!
    
    var viewSet : UIView!
    
    
    public func timerSet(view:UIView?)
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
        
        updateAnimation = Timer.scheduledTimer(timeInterval: 0.5,
                                               target: self,
                                               selector: #selector(self.updateAnimation(tm:)),
                                               userInfo: nil, repeats: true)
        
        updateAnimation.fire()
    }
    
    public func invalidate()
    {
        if self.metalView != nil {
            
        self.metalView.removeFromSuperview()
        self.metalView = nil
        
        self.alphaView.removeFromSuperview()
            
        timer.invalidate()
        updateAnimation.invalidate()
            
        }
    }
    
    @objc private func update(tm: Timer)
    {
  
        if self.metalView == nil {
            
            ScreenAnimation.screenAnimation = 11
            self.setupView()
           
        }else{
            
            self.metalView.removeFromSuperview()
            self.metalView = nil
            
            timer.invalidate()
            updateAnimation.invalidate()
            alphaView.alpha = 0
            
        }
        
    }
    
    @objc private func updateAnimation(tm: Timer)
    {
        
        alphaViewSetting()
        
    }
    
    private func setDesign()
    {
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
    }
    
    private func setupView()
    {
        
        if self.metalView == nil {
            
            setDesign()
            self.aAPLRenderer.instanceWithView(view: ViewAnimation.viewAnimation.animateImage(target: self.metalView) as! MTKView)
            
        }
    }
    
    public func metalPosition(point:CGPoint,view:UIView)
    {
        ScreenAnimation.screenAnimation = 11
        self.viewSet = view
         setDesign()
        self.aAPLRenderer.instanceWithView(view: ViewAnimation.viewAnimation.animateSet(target: self.metalView,point: point) as! MTKView)
    }
    private func alphaViewSetting()
    {
        alphaView.isPaused = true
        alphaView.enableSetNeedsDisplay = true
        alphaView.sampleCount = 4
        
        tessellationPipeline = tessellationPipeline.initWithMTKView(mtkView: alphaView )
        tessellationPipeline.wireframe = false
        
        alphaView.draw()
       
    }
}
