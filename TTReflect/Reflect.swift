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
    optional func setupReplaceClass() -> [String: AnyObject]
    optional func setupReplacePropertyName() -> [String: String]
}

extension NSObject: TTReflectProtocol {
    
//    struct ReplaceAttribute {
//        static var replaceClass: [String: AnyObject]?
//        static var replacePropertyName: [String: String]?
//    }
//    
//    var replaceClass: [String: AnyObject]? {
//        get {
//            return objc_getAssociatedObject(self, &ReplaceAttribute.replaceClass) as! [String: AnyObject]?
//        }
//        set {
//            if let newValue = newValue {
//                objc_setAssociatedObject(self, &ReplaceAttribute.replaceClass, newValue as [String: AnyObject]?, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
//            }
//        }
//    }
//    var replacePropertyName: [String: String]? {
//        get {
//            return objc_getAssociatedObject(self, &ReplaceAttribute.replacePropertyName) as! [String: String]?
//        }
//        set {
//            if let newValue = newValue {
//                objc_setAssociatedObject(self, &ReplaceAttribute.replacePropertyName, newValue as [String: String]?, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
//            }
//        }
//    }
    
    func setProperty(json: AnyObject!) {
        // check protocol
        var replaceClass: [String: AnyObject]?
        var replacePropertyName: [String: String]?
        if self.respondsToSelector("setupReplaceClass") {
            let res = self.performSelector("setupReplaceClass")
            replaceClass = res.takeUnretainedValue() as? [String: AnyObject]
        }
        if self.respondsToSelector("setupReplacePropertyName") {
            let res = self.performSelector("setupReplacePropertyName")
            replacePropertyName = res.takeUnretainedValue() as? [String: String]
        }
        
        let mirror = Mirror(reflecting: self)
        for item in mirror.children {
            let key = item.label!
            //
            self.setValue(json!.valueForKey(key), forKey: key)
            if let _ = replaceClass {
                for nameKey in replaceClass!.keys {
                    if key == nameKey {
                        let arr = Reflect.modelArray(json!.valueForKey(key), type: Tag.self)
                        self.setValue(arr, forKey: key)
                    }
                }
            }
            //
        }
        if let _ = replacePropertyName {
            for key in replacePropertyName!.keys {
                self.setValue(json!.valueForKey(key), forKey: replacePropertyName![key]!)
            }
        }
    }
}
