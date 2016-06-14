//
//  Reflect.swift
//  TTReflect
//
//  Created by TifaTsubasa on 16/5/27.
//  Copyright © 2016年 tifatsubasa. All rights reserved.
//

import Foundation

public class Reflect<M: NSObject> {
  
  public static func model<T: NSObject>(json json: AnyObject?, type: T.Type) -> T {
    return Reflect<T>.mapObject(json: json)
  }
  
  public static func mapObject(json json: AnyObject?) -> M {
    guard let json = json else { return M() }
    guard json is NSDictionary || json is [String: AnyObject] else {
      debugPrint("Reflect error: Mapping model without a dictionary json")
      return M()
    }
    let model = M()
    model.mapProperty(json)
    return model
  }
  
  public static func mapObject(data data: NSData?) -> M {
    guard let data = data else { return M() }
    do {
      let json = try NSJSONSerialization.JSONObjectWithData(data, options: .MutableContainers)
      return Reflect<M>.mapObject(json: json)
    } catch {
      debugPrint("Serializat json error: \(error)")
    }
    return M()
  }
  
  public static func mapObjects(json json: AnyObject?) -> [M] {
    guard let json = json else {
      return [M]()
    }
    guard json is NSArray || json is [AnyObject] else {
      debugPrint("Reflect error: Mapping object array without a array json")
      return [M]()
    }
    
    guard let arrayJson =  json as? [AnyObject] else {
      debugPrint("Reflect error: Mapping object array without a array json")
      return [M]()
    }
    let models: [M] = arrayJson.map {
      let model = M()
      model.mapProperty($0)
      return model
    }
    return models
  }
}

@objc
public protocol TTReflectProtocol {
  optional func setupMappingReplaceProperty() -> [String: String]
  optional func setupMappingObjectClass() -> [String: AnyClass]
  optional func setupMappingElementClass() -> [String: AnyClass]
  optional func setupMappingIgnorePropertyNames() -> [String]
}
extension NSObject: TTReflectProtocol {}


extension NSObject {
  // main function
  private func mapProperty(json: AnyObject) {
    if json is NSNull { return }
    
    // mapping setting
    let replacePropertyName = self.getMappingReplaceProperty()
    let ignorePropertyNames = self.getMappingIgnorePropertyNames()
    let mappingObjectClass = self.getMappingObjectClass()
    debugPrint("replacePropertyName: ", replacePropertyName)
    debugPrint("ignorePropertyNames: ", ignorePropertyNames)
    
    let keys = ergodicObjectKeys()
    for key in keys {
      let jsonKey = replacePropertyName[key] ?? key
      var value = json.valueForKey(jsonKey)
      
      guard !ignorePropertyNames.contains(key) else {continue}  // ignore property
      if let value =  value as? NSNull {  // ignore null porperty
        debugPrint("Reflect error: The key \(jsonKey) value is \(value)")
        continue
      }
      
      // map sub object
      if mappingObjectClass.keys.contains(jsonKey) {
        mapSubObject(key, jsonKey: jsonKey, mappingObjectClass: mappingObjectClass, value: &value!)
      }
      
      // map sub array
      setPropertyValue(value, forKey: key)
      
    }
  }
  
  private func mapSubObject(key: String, jsonKey: String, mappingObjectClass: [String: AnyClass], inout value: AnyObject) {
    guard let objClass = mappingObjectClass[jsonKey] as? NSObject.Type else {
      fatalError("Reflect error: Sub-model is not a subclass of NSObject")
    }
    let model = objClass.init()
    guard value is NSDictionary || value is [String: AnyObject] else {
      debugPrint("Reflect error: Error key: \(key) -- mapping sub-model without a dictionary json")
      return
    }
    model.mapProperty(value)
    value = model
  }
  
  private func mapSubObjectArray(key: String, jsonKey: String, inout value: AnyObject) {
    let mappingElementClass = self.getMappingElementClass()
    guard mappingElementClass.keys.contains(jsonKey) else {return}
    guard let objClass = mappingElementClass[jsonKey] as? NSObject.Type else {
      fatalError("Reflect error: Sub-model is not a subclass of NSObject")
    }
    let model = objClass.init()
    guard value is NSDictionary || value is [String: AnyObject] else {
      debugPrint("Reflect error: Error key: \(key) -- mapping sub-model without a dictionary json")
      return
    }
    model.mapProperty(value)
    value = model
  }
  
  private func setPropertyValue(value: AnyObject?, forKey key: String) {
    
    setValue(value, forKey: key)
    
  }
  
  //
  func ergodicObjectKeys() -> [String] {
    var keys = [String]()
    let mirror = Mirror(reflecting: self)
    keys = mirror.children.map {$0.label!}
    return keys
  }
  
  private func getMappingReplaceProperty() -> [String: String] {
    var replacePropertyName = [String: String]()
    guard self.respondsToSelector(#selector(TTReflectProtocol.setupMappingReplaceProperty)) else {return replacePropertyName}
    let res = self.performSelector(#selector(TTReflectProtocol.setupMappingReplaceProperty))
    replacePropertyName = res.takeUnretainedValue() as! [String: String]
    return replacePropertyName
  }
  
  private func getMappingIgnorePropertyNames() -> [String] {
    var ignorePropertyNames = [String]()
    guard self.respondsToSelector(#selector(TTReflectProtocol.setupMappingIgnorePropertyNames)) else {return ignorePropertyNames}
    let res = self.performSelector(#selector(TTReflectProtocol.setupMappingIgnorePropertyNames))
    ignorePropertyNames = res.takeUnretainedValue() as! [String]
    return ignorePropertyNames
  }
  
  private func getMappingObjectClass() -> [String: AnyClass] {
    var mappingObjectClass = [String: AnyClass]()
    guard self.respondsToSelector(#selector(TTReflectProtocol.setupMappingObjectClass)) else {return mappingObjectClass}
    let res = self.performSelector(#selector(TTReflectProtocol.setupMappingObjectClass))
    mappingObjectClass = res.takeUnretainedValue() as! [String: AnyClass]
    return mappingObjectClass
  }
  
  private func getMappingElementClass() -> [String: AnyClass] {
    var mappingElementClass = [String: AnyClass]()
    guard self.respondsToSelector(#selector(TTReflectProtocol.setupMappingElementClass)) else {return mappingElementClass}
    let res = self.performSelector(#selector(TTReflectProtocol.setupMappingElementClass))
    mappingElementClass = res.takeUnretainedValue() as! [String: AnyClass]
    return mappingElementClass
  }
}
