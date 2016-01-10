//
//  Reflect.swift
//  TTReflect
//
//  Created by 谢许峰 on 16/1/10.
//  Copyright © 2016年 tifatsubasa. All rights reserved.
//

import Foundation

class Reflect {
    static func model<T: NSObject>(json: AnyObject?, type: T.Type) -> T? {
        let model = T()
        if let _ = json {
            model.setProperty(json)
            return model
        }
        return nil
    }
    static func model<T: NSObject>(data: NSData?, type: T.Type) -> T? {
        let model = T()
        if let _ = data {
            do {
                let json : AnyObject! = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers)
                model.setProperty(json)
                return model
            } catch {
                print("Serializat json error, \(error)")
            }
        }
        return nil
    }
    // reflect model array
    static func modelArray<T: NSObject>(json: AnyObject?, type: T.Type) -> [T]? {
        var modelArray = [T]()
        if let _ = json {
            if json is NSArray {
                for jsonObj in json as! NSArray {
                    let model = T()
                    model.setProperty(jsonObj)
                    modelArray.append(model)
                }
                return modelArray
            } else {
                print("input json not be a array!")
            }
            
        }
        return nil
    }
    static func modelArray<T: NSObject>(data: NSData?, type: T.Type) -> [T]? {
        var modelArray = [T]()
        if let _ = data {
            do {
                let json: AnyObject! = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers)
                if json is NSArray {
                    for jsonObj in json as! NSArray {
                        let model = T()
                        model.setProperty(jsonObj)
                        modelArray.append(model)
                    }
                    return modelArray
                } else {
                    print("Serializat json not be a array!")
                }
            } catch {
                print("Serializat json error, \(error)")
            }
        }
        return nil
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
