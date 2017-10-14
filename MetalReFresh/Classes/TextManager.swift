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
    static var fileURL = [URL]()
    static var imageData = [Data]()
    
    public func saveMehod(images:[UIImage])
    {
        
        fileManager.fileExists(atPath: messageManagement.defaultsPath, isDirectory: &isDir)
        
        if isDir.boolValue {
            
            try! fileManager.createDirectory(atPath: messageManagement.defaultsPath ,withIntermediateDirectories: true, attributes: nil)
            TextManager.fileURL.append(URL(fileURLWithPath: messageManagement.defaultsPath).appendingPathComponent(fileNamed+"\(ObjectDefaults().objectSetIndexDefaults())"))

            TextManager.imageData.append(UIImagePNGRepresentation(images[ObjectDefaults().objectSetIndexDefaults()])!)
            try! TextManager.imageData[ObjectDefaults().objectSetIndexDefaults()].write(to: TextManager.fileURL[ObjectDefaults().objectSetIndexDefaults()], options: .atomic)
            
        }
    }
    
    public func writeObject(images:[UIImage])
    {
        saveMehod(images: images)
    }
    
    public func readObject()
    {
        
        for i in 0...ObjectDefaults().objectSetIndexDefaults(){
            
            TextManager.fileURL.append(URL(fileURLWithPath: messageManagement.defaultsPath).appendingPathComponent(fileNamed+"\(i)"))
            
            TextManager.imageData.append(try! Data(contentsOf: TextManager.fileURL[i],options: NSData.ReadingOptions.mappedIfSafe))
            
            uiImage.append(UIImage(data:TextManager.imageData[i])!)
            
            guard TextManager.fileURL[i].path != "" else {
                
                return
            }
            
            try! TextManager.imageData[i].write(to: TextManager.fileURL[i], options: .atomic)
            ImageEntity.imageArray.append(uiImage[i])
            
        }
        
    }
    
    public func removeObject(index:Int)
    {
        
        try! FileManager.default.removeItem(at: URL(fileURLWithPath: messageManagement.defaultsPath).appendingPathComponent(fileNamed+"\(index)"))
        
    }
}

