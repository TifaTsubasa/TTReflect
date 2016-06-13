//
//  Reflect.swift
//  TTReflect
//
//  Created by TifaTsubasa on 16/5/27.
//  Copyright © 2016年 tifatsubasa. All rights reserved.
//

import Foundation

public class Reflect<M: NSObject> {
  public static func mapObject(json json: AnyObject?) -> M {
    guard let json = json else { return M() }
    guard json is NSDictionary else {
      debugPrint("Reflect error: mapping model without a dictionary json")
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
    guard json is NSDictionary else {
      debugPrint("Reflect error: mapping model without a dictionary json")
      return [M]()
    }
    let models = [M]()
//    model.mapProperty(json)
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
    if json is NSNull {
      return
    }
    // mapping setting
    let replacePropertyName = self.getMappingReplaceProperty()
    let ignorePropertyNames = self.getMappingIgnorePropertyNames()
    debugPrint("replacePropertyName: ", replacePropertyName)
    debugPrint("ignorePropertyNames: ", ignorePropertyNames)
    
    let keys = ergodicObjectKeys()
    for key in keys {
      
      let jsonKey = replacePropertyName[key] ?? key
      let value = json.valueForKey(jsonKey)
      guard !ignorePropertyNames.contains(key) else {continue}  // ignore property
      
      if let value =  value as? NSNull {
        debugPrint("Reflect error: The key \(jsonKey) value is \(value)")
      } else {
        self.setPropertyValue(value, forKey: key)
      }
    }
  }
  
  private func setPropertyValue(value: AnyObject?, forKey key: String) {
    debugPrint("property '\(key)' class: \(valueForKey(key)?.classForCoder)")
    setValue(value, forKey: key)
  }
  
  //
  func ergodicObjectKeys() -> [String] {
    var keys = [String]()
    let mirror = Mirror(reflecting: self)
    keys = mirror.children.map { $0.label! }
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
}