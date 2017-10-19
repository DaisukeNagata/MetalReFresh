//
//  ObjectDefaults.swift
//  MetalReFresh
//
//  Created by nagatadaisuke on 2017/10/01.
//

import Foundation

public class ObjectDefaults : NSObject {
    
    var imageData = UIImage()
    public var userArray = Array<Data>()
    public var imageUserArray :Array<UIImage> = []
    public var userDefaults = UserDefaults.standard
    
    public func objectDefaults(index:Int,images:[UIImage])
    {
        
        let dataImages: [Data] = images.map { (image) -> Data in
            UIImagePNGRepresentation(image)!
        }
        
        userDefaults.set(index, forKey: "index")
        userDefaults.set(dataImages, forKey: "image")
        let userImages = userDefaults.object(forKey: "image")
        
        userArray += userImages as! Array<Data>
        
        for i in 0...userArray.count-1 {
            
            imageData = UIImage(data:userArray[i])!
            imageUserArray.append(imageData)
            
        }
    }
    
    public func objectIndexDefaults(index:Int)
    {
        userDefaults.set(index, forKey: "index")
    }
    
    public func objectSetIndexDefaults()->Int
    {
        return ObjectDefaults().userDefaults.integer(forKey: "index")
    }
    
    public func setObject()->(Array<UIImage>,Int)
    {
        let userImages =   ObjectDefaults().userDefaults.object(forKey: "image")
        let index =   ObjectDefaults().userDefaults.integer(forKey: "index")
        
        guard index > 0 else {
            
            return (imageUserArray,index)
            
        }
        
        for i in 0...index-1 {
            
            userArray += userImages as! Array<Data>
            imageData = UIImage(data:userArray[i])!
            imageUserArray.append(imageData)
            
        }
        
        return (imageUserArray,index)
    }
    
}
