//
//  Encode.swift
//  MetalReFresh
//
//  Created by 永田大祐 on 2017/10/14.
//

import Foundation

public class EncodesSample: NSObject{
    
    open var imageData = Array<String>()
    
    public func encodeSet(images:UIImage?,index:Int) -> String
    {
   
        let dataSet = images?.description.data(using: String.Encoding.utf8)
        let base64Str = dataSet?.base64EncodedString(options: Data.Base64EncodingOptions.lineLength64Characters)
        for _ in 0...index{
            
            imageData.append(base64Str!)
        }
        
        return imageData[index].description
    }
}
