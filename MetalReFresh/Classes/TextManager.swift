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
    let fileNamed = "saveMehod.text"
    var uiImage = Array<UIImage>()
    
    public func saveMehod(images:[UIImage])
    {
        
        fileManager.fileExists(atPath: messageManagement.defaultsPath, isDirectory: &isDir)
        
        if isDir.boolValue {
            
            try! fileManager.createDirectory(atPath: messageManagement.defaultsPath ,withIntermediateDirectories: true, attributes: nil)
            let fileURL = URL(fileURLWithPath: messageManagement.defaultsPath).appendingPathComponent(fileNamed)
            
            
            for i in 0...images.count-1 {
                
            let imageData = UIImageJPEGRepresentation(images[i], 1.0)
            try! imageData?.write(to: fileURL, options: .atomic)
                
            }
        }
    }
    
    public func writeObject(images:[UIImage])
    {
        saveMehod(images: images)
    }
    
    public func readObject()->Array<UIImage>?
    {
        
        uiImage.removeAll()
        
        let filePath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        
        let fileURL = URL(fileURLWithPath: filePath).appendingPathComponent(fileNamed)
        
        uiImage = [UIImage(contentsOfFile: fileURL.path)!]
        
        guard fileURL.path != "" else {
            
            return nil

        }

        ImageEntity.imageArray.append(uiImage.last!)
            
        return  uiImage

    }
    
    
    public func removeObject()
    {
        if let dir = FileManager.default.urls( for: .documentDirectory, in: .userDomainMask ).last {
            
            let fileName = dir.appendingPathComponent(try! fileManager.contentsOfDirectory(atPath: messageManagement.defaultsPath)[0])
            
            try! FileManager.default.removeItem(at: fileName)
            
        }
    }
}

