//
//  Reflect.swift
//  TTReflect
//
//  Created by 谢许峰 on 16/1/10.
//  Copyright © 2016年 tifatsubasa. All rights reserved.
//

import Foundation

class Reflect {
    static func reflectPropertyArray<T: NSObject>(json: AnyObject?, type: T.Type) -> [T] {
        var modelArray = [T]()
        for jsonObj in json as! NSArray {
            let model = T()
            model.setProperty(jsonObj)
            modelArray.append(model)
            print(jsonObj)
        }
        //        print(self.dynamicType)
        return modelArray
    }
    static func model<T: NSObject>(data: NSData?, type: T.Type) -> T {
        let model = T()
        if let _ = data {
            do {
                let json : AnyObject! = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers)
                model.setProperty(json)
            } catch {
                print("Serializat json error, \(error)")
            }
        }
        return model
    }
}

extension NSObject {
//    var replacePropertyName: String
    
    func setProperty(json: AnyObject?) {
        if let _ = json {
            let mirror = Mirror(reflecting: self)
            
            for item in mirror.children {
                let key = item.label!
                self.setValue(json!.valueForKey(key), forKey: key)
            }
        }
    }
}
