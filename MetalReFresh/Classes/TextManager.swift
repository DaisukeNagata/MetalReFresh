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
    // ファイル名
    let fileName = "saveMehod.text"
    
    public func saveMehod(st:String,index:Int)
    {
        
        fileManager.fileExists(atPath: messageManagement.defaultsPath, isDirectory: &isDir)
        
        if isDir.boolValue {
            
            try! fileManager.createDirectory(atPath: messageManagement.defaultsPath ,withIntermediateDirectories: true, attributes: nil)
            // 保存した表示
            let fileObject = st+"\(index)"
            
            // 保存処理
            try! fileObject.write(toFile: "\(messageManagement.defaultsPath)/\(fileName)", atomically: true, encoding: String.Encoding.utf8)
            
        }
    }
    
    public func writeObject(st:String,index:Int)
    {
        saveMehod(st: st,index:index)
    }
    
    public func readObject(index:Int)->String
    {
        if let dir = FileManager.default.urls( for: .documentDirectory, in: .userDomainMask ).first {
            
            let fileName = dir.appendingPathComponent(try! fileManager.contentsOfDirectory(atPath: messageManagement.defaultsPath)[0])
            
            do {
   
                return try String( contentsOf: fileName, encoding: String.Encoding.utf8 )
            } catch {
                
                //Preparation of FileManager
            }
        }
        
        return ""
    }
    
    public func removeObject(index:Int)
    {
        guard try! fileManager.contentsOfDirectory(atPath: messageManagement.defaultsPath)[index] != "" else {
            return
        }
      
        try! fileManager.removeItem(atPath: "\(messageManagement.defaultsPath)/\(fileName)")
    }
}
