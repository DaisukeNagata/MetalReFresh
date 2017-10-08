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
    
    open static var indexCount = Int()
    open var userDefaults = UserDefaults.standard
    // ファイル名
    let fileName = "saveMehod.text"
    
    public func saveMehod(images:[UIImage],index:Int)
    {
        
        fileManager.fileExists(atPath: messageManagement.defaultsPath, isDirectory: &isDir)
        
        if isDir.boolValue {
            
            try! fileManager.createDirectory(atPath: messageManagement.defaultsPath ,withIntermediateDirectories: true, attributes: nil)
            
            let fileObject = images.description+"\(index)"
            
            try! fileObject.write(toFile: "\(messageManagement.defaultsPath)/\(fileName)", atomically: true, encoding: String.Encoding.utf8)
            
            userDefaults.set([index], forKey: "index")
            
        }
    }
    
    public func writeObject(images:[UIImage],index:Int)
    {
        saveMehod(images: images,index:index)
    }
    
    public func readObject(index:Int)->String
    {
        if let dir = FileManager.default.urls( for: .documentDirectory, in: .userDomainMask ).first {
            
            let fileName = dir.appendingPathComponent(try! fileManager.contentsOfDirectory(atPath: messageManagement.defaultsPath)[0])
            
            do {
        
                let arry = try String( contentsOf: fileName, encoding: String.Encoding.utf8 )
                let flags : Array<String> = arry.characters.split{$0 == "}"}.map(String.init)
                
                print(flags)
                

                return flags.description
                
                
            } catch {
                
                //Preparation of FileManager
            }
        }
        return ""
    }
    
    public func removeObject(index:Int)
    {
        try! fileManager.removeItem(atPath: "\(messageManagement.defaultsPath)/\(fileName)")
    }
}
