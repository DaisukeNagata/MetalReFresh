//
//  Encode.swift
//  MetalReFresh
//
//  Created by 永田大祐 on 2017/10/14.
//

import Foundation

public class EncodesSample: NSObject{
    
    let data = Data()
    open var imageData = Array<String>()
    
    public func encodeSet(images:UIImage?,index:Int) -> String
    {
        let str = images?.description
        let data : Data = (str?.data(using: .utf8))!
        let encode = data.base64EncodedString(options: [])
        
        for _ in 0...index{
            
            imageData.append(encode)
        }
        
        return imageData[index].description
    }
}
