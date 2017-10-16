//
//  TextManager.swift
//  MetalReFresh
//
//  Created by nagatadaisuke on 2017/10/07.
//

import Foundation

public class TextManager: NSObject {
    
    let fileManager = FileManager.default
    var isDir : ObjCBool = true
    let fileNamed = "saveMethod.text"
    var uiImage = Array<UIImage>()
    var fileURL = [URL]()
    var imageData = [Data]()
    
    public func saveMethod(images:[UIImage])
    {
        
        fileManager.fileExists(atPath: messageManagement.defaultsPath, isDirectory: &isDir)
        
        if isDir.boolValue {
            
            try! fileManager.createDirectory(atPath: messageManagement.defaultsPath ,withIntermediateDirectories: true, attributes: nil)
           
            for i in 0...images.count-1{
                
            imageData.append(UIImagePNGRepresentation(images[i])!)
            fileURL.append(URL(fileURLWithPath: messageManagement.defaultsPath).appendingPathComponent(fileNamed+"\(i)"))
                
            }

            try! imageData[ObjectDefaults().objectSetIndexDefaults()].write(to: fileURL[ObjectDefaults().objectSetIndexDefaults()], options: .atomic)
            
        }
    }
    
    public func writeObject(images:[UIImage])
    {
        saveMethod(images: images)
    }
    
    public func readObject()
    {
        
        for i in 0...ObjectDefaults().objectSetIndexDefaults(){
            
            fileURL.append(URL(fileURLWithPath: messageManagement.defaultsPath).appendingPathComponent(fileNamed+"\(i)"))
            
            imageData.append(try! Data(contentsOf: fileURL[i],options: NSData.ReadingOptions.mappedIfSafe))
            
            uiImage.append(UIImage(data:imageData[i])!)
            
            guard fileURL[i].path != "" else {
                
                return
            }
            
            try! imageData[i].write(to: fileURL[i], options: .atomic)
            ImageEntity.imageArray.append(uiImage[i])
            
        }
        
    }
    
    public func removeObject(index:Int)
    {
        
        try! FileManager.default.removeItem(at: URL(fileURLWithPath: messageManagement.defaultsPath).appendingPathComponent(fileNamed+"\(index)"))
        
    }
}

