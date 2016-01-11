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

@objc
protocol TTReflectProtocol {
    optional func setupReplacePropertyName() -> [String: String]
    optional func setupReplaceObjectClass() -> [String: AnyObject]
    optional func setupReplaceElementClass() -> [String: AnyObject]
}

extension NSObject: TTReflectProtocol {
    
    
    
    func setProperty(json: AnyObject!) {
        // check protocol
        var replacePropertyName: [String: String]?
        var replaceObjectClass: [String: AnyObject]?
        var replaceElementClass: [String: AnyObject]?
        if self.respondsToSelector("setupReplacePropertyName") {
            let res = self.performSelector("setupReplacePropertyName")
            replacePropertyName = res.takeUnretainedValue() as? [String: String]
        }
        if self.respondsToSelector("setupReplaceObjectClass") {
            let res = self.performSelector("setupReplaceObjectClass")
            replaceObjectClass = res.takeUnretainedValue() as? [String: AnyObject]
        }
        if self.respondsToSelector("setupReplaceElementClass") {
            let res = self.performSelector("setupReplaceElementClass")
            replaceElementClass = res.takeUnretainedValue() as? [String: AnyObject]
        }
        
        let mirror = Mirror(reflecting: self)
        for item in mirror.children {
            let key = item.label!
            self.setValue(json!.valueForKey(key), forKey: key)
            //
            let testCls = self.valueForKey(key)
//            print(key, testCls?.classForKeyedArchiver)
            if testCls is NSDictionary {
                print(testCls!.classForCoder)
            }
            let images = Images()
//            print(images.classForCoder)
            //
            if key == "images" {
                if let cls = NSClassFromString(NSBundle.mainBundle().objectForInfoDictionaryKey("CFBundleName")!.description + "." + "Images") as? NSObject.Type{
                    let obj = cls.init()
                    //                obj.self
//                    print(key, obj, json.valueForKey(key))
                    obj.setProperty(json.valueForKey(key))
                    self.setValue(obj, forKey: key)
//                    print(key, obj.self)
                }
            }
            
            
            // set sub model
            if let _ = replaceObjectClass {
                for nameKey in replaceObjectClass!.keys {
                    if key == nameKey {
//                        let submodel = Reflect.model(json!.valueForKey(key), type: replaceObjectClass[key])
                        
                    }
                }
            }
            // set sub model array
            if let _ = replaceElementClass {
                for nameKey in replaceElementClass!.keys {
                    if key == nameKey {
                        let type = replaceElementClass![key] as! Tag.Type
                        let arr = Reflect.modelArray(json!.valueForKey(key), type: type)
                        self.setValue(arr, forKey: key)
                    }
                }
            }
        }
        // set replace property name
        if let _ = replacePropertyName {
            for key in replacePropertyName!.keys {
                self.setValue(json!.valueForKey(key), forKey: replacePropertyName![key]!)
            }
        }
    }
}
