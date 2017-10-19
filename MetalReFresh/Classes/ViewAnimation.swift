//
//  ViewAnimation.swift
//  sampleAnmation
//
//  Created by 永田大祐 on 2017/02/25.
//  Copyright © 2017年 永田大祐. All rights reserved.
//

import UIKit

 class ViewAnimation: UIView {
    
    static let viewAnimation = ViewAnimation()
    
    override init(frame:CGRect)
    {
        
        super.init(frame: frame)
        
    }
    
    required public init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
    
     func animateImage(target:UIView)->UIView
     {

        target.frame = CGRect(x:UIScreen.main.bounds.size.width/2-30,y:-UIScreen.main.bounds.size.height/9,width:60,height:60)
        target.layer.cornerRadius = 20
        target.layer.masksToBounds = true

        let angle:CGFloat = CGFloat(Double.pi)
        
        UIView.animate(
            withDuration: 1.0,
            animations: {() -> Void  in
                
                target.transform = CGAffineTransform(rotationAngle: angle)
                target.transform = CGAffineTransform.identity
                
        },
            completion: { (Bool) -> Void in

               _ = self.animateImage(target: target)
        })
        
        return target
        
    }
}
