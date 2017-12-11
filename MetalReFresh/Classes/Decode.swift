//
//  Decode.swift
//  MetalReFresh
//
//  Created by 永田大祐 on 2017/12/10.
//

import Foundation

public class DecodesSample: NSObject{
    
    open var imageData = Array<String>()
    
    public func Decode(st:String?,index:Int) -> String
    {
        let decodedData = Data(base64Encoded: st!,
                                 options: Data.Base64DecodingOptions.ignoreUnknownCharacters)
        
        guard decodedData != nil else{ return st! }

        let decodedString = String(data: decodedData!, encoding: String.Encoding.utf8)
        
        for _ in 0...index{
            
            imageData.append(decodedString!)
        }
        
        return imageData[index].description
    }
}
