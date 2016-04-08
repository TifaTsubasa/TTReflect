//
//  Reflect.swift
//  TTReflect
//
//  Created by 谢许峰 on 16/1/10.
//  Copyright © 2016年 tifatsubasa. All rights reserved.
//

import Foundation

public class Reflect {
    public static func model<T: NSObject>(json json: AnyObject?, type: T.Type) -> T {
        if let _ = json {
            let model = T()
            if json is NSDictionary {
                model.setProperty(json)
                return model
            } else {
                debugPrint("error: reflect model need a dictionary json")
            }
        }
        return T()
    }
    public static func model<T: NSObject>(data data: NSData?, type: T.Type) -> T {
        if let _ = data {
            let model = T()
            do {
                let json : AnyObject! = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers)
                if json is NSDictionary {
                    model.setProperty(json)
                    return model
                } else {
                    debugPrint("error: reflect model need a dictionary json")
                }
            } catch {
                debugPrint("Serializat json error, \(error)")
            }
        }
        return T()
    }
    public static func model<T: NSObject>(plistName: String?, type: T.Type) -> T {
        let plistPath = NSBundle.mainBundle().pathForResource(plistName, ofType: "plist")
        if let _ = plistPath {
            let plistUrl = NSURL.fileURLWithPath(plistPath!)
            let json = NSDictionary(contentsOfURL: plistUrl)
            let model = T()
            if let _ = json {
                model.setProperty(json)
                return model
            }
        } else {
            debugPrint("error plist name")
        }
        return T()
    }
    // reflect model array
    public static func modelArray<T: NSObject>(json json: AnyObject?, type: T.Type) -> [T] {
        if let _ = json {
            var modelArray = [T]()
            if json is NSArray {
                for jsonObj in json as! NSArray {
                    let model = T()
                    model.setProperty(jsonObj)
                    modelArray.append(model)
                }
                return modelArray
            } else {
                debugPrint("error: reflect model need a array json")
            }
            
        }
        return [T]()
    }
    public static func modelArray<T: NSObject>(data data: NSData?, type: T.Type) -> [T] {
        if let _ = data {
            var modelArray = [T]()
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
                    debugPrint("error: reflect model need a array json")
                }
            } catch {
                debugPrint("Serializat json error, \(error)")
            }
        }
        return [T]()
    }
    public static func modelArray<T: NSObject>(plistName: String?, type: T.Type) -> [T] {
        let plistPath = NSBundle.mainBundle().pathForResource(plistName, ofType: "plist")
        if let _ = plistPath {
            let json = NSArray(contentsOfURL: NSURL.fileURLWithPath(plistPath!))
            var modelArray = [T]()
            if let _ = json {
                for jsonObj in json! {
                    let model = T()
                    model.setProperty(jsonObj)
                    modelArray.append(model)
                }
                return modelArray
            }
        } else {
            debugPrint("error plist name")
        }
        return [T]()
    }
}

@objc
protocol TTReflectProtocol {
    optional func setupReplacePropertyName() -> [String: String]
    optional func setupReplaceObjectClass() -> [String: String]
    optional func setupReplaceElementClass() -> [String: String]
}

extension NSObject: TTReflectProtocol {
    
    func setProperty(json: AnyObject!) {
        // check protocol
        var replacePropertyName: [String: String]?
        var replaceObjectClass: [String: String]?
        var replaceElementClass: [String: String]?
        if self.respondsToSelector(#selector(TTReflectProtocol.setupReplacePropertyName)) {
            let res = self.performSelector(#selector(TTReflectProtocol.setupReplacePropertyName))
            replacePropertyName = res.takeUnretainedValue() as? [String: String]
        }
        if self.respondsToSelector(#selector(TTReflectProtocol.setupReplaceObjectClass)) {
            let res = self.performSelector(#selector(TTReflectProtocol.setupReplaceObjectClass))
            replaceObjectClass = res.takeUnretainedValue() as? [String: String]
        }
        if self.respondsToSelector(#selector(TTReflectProtocol.setupReplaceElementClass)) {
            let res = self.performSelector(#selector(TTReflectProtocol.setupReplaceElementClass))
            replaceElementClass = res.takeUnretainedValue() as? [String: String]
        }
        
        var keys = [String]()
        
        if #available(iOS 8.0, *) {
            let mirror = Mirror(reflecting: self)
            for item in mirror.children {
                keys.append(item.label!)
            }
        } else {
            var propNum: UInt32 = 0
            let propList = class_copyPropertyList(self.classForCoder, &propNum)
            for index in 0..<numericCast(propNum) {
                let prop: objc_property_t = propList[index]
                keys.append(String(UTF8String: property_getName(prop))!)
            }
        }
        
        for key in keys {
            if let value =  json!.valueForKey(key) as? NSNull {
                debugPrint("The key \(key) value is \(value)")
            } else {
                self.setValue(json!.valueForKey(key), forKey: key)
            }
            
            // set sub model
            if let _ = replaceObjectClass {
                if replaceObjectClass!.keys.contains(key) {
                    let type = replaceObjectClass![key]!
                    if let cls = NSClassFromString(NSBundle.mainBundle().objectForInfoDictionaryKey("CFBundleName")!.description + "." + type) as? NSObject.Type {
                        let obj = cls.init()
                        obj.setProperty(json.valueForKey(key));
                        self.setValue(obj, forKey: key)
                    } else {
                        debugPrint("setup replace object class with error name!");
                    }
                }
            }
            // set sub model array
            if let _ = replaceElementClass {
                if replaceElementClass!.keys.contains(key) {
                    let type = replaceElementClass![key]!
                    
                    if let cls = NSClassFromString(NSBundle.mainBundle().objectForInfoDictionaryKey("CFBundleName")!.description + "." + type) as? NSObject.Type {
                        if let subJsonArray = json!.valueForKey(key) as? NSArray {
                            var subModelArray = [NSObject]()
                            for subJson in subJsonArray {
                                let obj = cls.init()
                                obj.setProperty(subJson);
                                subModelArray.append(obj)
                            }
                            self.setValue(subModelArray, forKey: key)
                            
                        } else {
                            debugPrint("parse sub model array without array json")
                        }
                    } else {
                        debugPrint("setup replace object class with error name!");
                    }
                }
            }
        }
        // set replace property name
        if let _ = replacePropertyName {
            for key in replacePropertyName!.keys {
                if let value =  json!.valueForKey(key) as? NSNull {
                    debugPrint("The key \(key) value is \(value)")
                } else {
                    self.setValue(json!.valueForKey(key), forKey: replacePropertyName![key]!)
                }
            }
        }
    }
}
