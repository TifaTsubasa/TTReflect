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
    if let json = json {
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
    if let data = data {
      let model = T()
      do {
        let json : AnyObject! = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers)
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
    if let plistPath = plistPath {
      let plistUrl = NSURL.fileURLWithPath(plistPath)
      let json = NSDictionary(contentsOfURL: plistUrl)
      let model = T()
      if let json = json {
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
    if let json = json {
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
    if let data = data {
      var modelArray = [T]()
      do {
        let json: AnyObject! = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers)
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
    if let plistPath = plistPath {
      let json = NSArray(contentsOfURL: NSURL.fileURLWithPath(plistPath))
      var modelArray = [T]()
      if let json = json {
        for jsonObj in json {
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
public protocol TTReflectProtocol {
  optional func setupReplacePropertyName() -> [String: String]
  optional func setupReplaceObjectClass() -> [String: String]
  optional func setupReplaceElementClass() -> [String: String]
}

extension NSObject: TTReflectProtocol {
  
  private func setProperty(json: AnyObject?) {
    // return when json is nil or null
    guard let json =  json else {
      return
    }
    if json is NSNull {
      return
    }
    
    // check protocol
    var replacePropertyName = getReplacePropertyName()
    var replaceObjectClass = getReplaceObjectClass()
    var replaceElementClass = getReplaceElementClass()
    
    let keys = genereteObjectKeys()
    
    for key in keys {
      
      let objKey = replacePropertyName[key] ?? key
      let value = json.valueForKey(objKey)
      
      let needReplaceObject = replaceObjectClass.keys.contains(objKey) ?? false
      let needReplaceElement = replaceElementClass.keys.contains(objKey) ?? false
      
      if needReplaceObject {
        let type = replaceObjectClass[objKey]!
        if let cls = NSClassFromString(NSBundle.mainBundle().objectForInfoDictionaryKey("CFBundleName")!.description + "." + type) as? NSObject.Type {
          let obj = cls.init()
          if let value = value {
            obj.setProperty(value)
          }
          self.setValue(obj, forKey: key)
        } else {
          debugPrint("setup replace object class with error name!");
        }
      }
      
      if needReplaceElement {
        let type = replaceElementClass[objKey]!
        
        if let cls = NSClassFromString(NSBundle.mainBundle().objectForInfoDictionaryKey("CFBundleName")!.description + "." + type) as? NSObject.Type {
          if let subJsonArray = value as? NSArray {
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
      
      if let value =  value as? NSNull {
        debugPrint("The key \(objKey) value is \(value)")
      } else {
        self.setPropertyValue(value, forKey: key)
      }
      
    }
  }
  
  private func setPropertyValue(value: AnyObject?, forKey key: String) {
    if self.valueForKey(key)?.classForCoder == value?.classForCoder {
      self.setValue(value, forKey: key)
    } else {
      if value != nil && !(value is NSDictionary) && !(value is NSArray) {
        debugPrint("The value have diff type when key is '\(key)'")
      }
    }
  }
  
  private func getReplacePropertyName() -> [String: String] {
    var replacePropertyName = [String: String]()
    if self.respondsToSelector(#selector(TTReflectProtocol.setupReplacePropertyName)) {
      let res = self.performSelector(#selector(TTReflectProtocol.setupReplacePropertyName))
      replacePropertyName = res.takeUnretainedValue() as! [String: String]
      var tmpReplacePropertyName = [String: String]()
      let _ = replacePropertyName.flatMap {
        tmpReplacePropertyName[$0.1] = $0.0
      }
      return tmpReplacePropertyName
    }
    return replacePropertyName
  }
  
  private func getReplaceObjectClass() -> [String: String] {
    if self.respondsToSelector(#selector(TTReflectProtocol.setupReplaceObjectClass)) {
      let res = self.performSelector(#selector(TTReflectProtocol.setupReplaceObjectClass))
      return res.takeUnretainedValue() as! [String: String]
    }
    return [String: String]()
  }
  
  private func getReplaceElementClass() -> [String: String] {
    if self.respondsToSelector(#selector(TTReflectProtocol.setupReplaceElementClass)) {
      let res = self.performSelector(#selector(TTReflectProtocol.setupReplaceElementClass))
      return res.takeUnretainedValue() as! [String: String]
    }
    return [String: String]()
  }
  
  private func genereteObjectKeys() -> [String] {
    var keys = [String]()
    if #available(iOS 8.0, *) {
      let mirror = Mirror(reflecting: self)
      keys = mirror.children.map {
        $0.label!
      }
    } else {
      var propNum: UInt32 = 0
      let propList = class_copyPropertyList(self.classForCoder, &propNum)
      for index in 0..<numericCast(propNum) {
        let prop: objc_property_t = propList[index]
        keys.append(String(UTF8String: property_getName(prop))!)
      }
    }
    return keys
  }
}
