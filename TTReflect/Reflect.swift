//
//  Reflect.swift
//  TTReflect
//
//  Created by TifaTsubasa on 16/5/27.
//  Copyright © 2016年 tifatsubasa. All rights reserved.
//

import Foundation

public class Reflect<M: NSObject> {
  
  // MARK: - reflect with json
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
  
  // MARK: - reflect with data
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
  
  public static func mapObjects(data data: NSData?) -> [M] {
    guard let data = data else { return [M]() }
    do {
      let json = try NSJSONSerialization.JSONObjectWithData(data, options: .MutableContainers)
      return Reflect<M>.mapObjects(json: json)
    } catch {
      debugPrint("Serializat json error: \(error)")
    }
    return [M]()
  }
  
  // MARK: - reflect with plist name
  public static func mapObject(plistName: String?) -> M {
    let plistPath = NSBundle.mainBundle().pathForResource(plistName, ofType: "plist")
    guard let path = plistPath else {
      debugPrint("Reflect error: Error plist name")
      return M()
    }
    let json = NSDictionary(contentsOfFile: path)
    return Reflect<M>.mapObject(json: json)
  }
  
  public static func mapObjects(plistName: String?) -> [M] {
    let plistPath = NSBundle.mainBundle().pathForResource(plistName, ofType: "plist")
    guard let path = plistPath else {
      debugPrint("Reflect error: Error plist name")
      return [M]()
    }
    let json = NSArray(contentsOfFile: path)
    return Reflect<M>.mapObjects(json: json)
  }
}

// MARK: - private function
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
    let mappingElementClass = self.getMappingElementClass()
    
    let keys = ergodicObjectKeys()
    for key in keys {
      let jsonKey = replacePropertyName[key] ?? key
      let jsonValue = json.valueForKey(jsonKey)
      
      guard !ignorePropertyNames.contains(key) else {continue}  // ignore property
      guard var value = jsonValue else {return}
      if value is NSNull {  // ignore null porperty
        debugPrint("Reflect error: The key \(jsonKey) value is \(value)")
        continue
      }
      
      // map sub object
      if mappingObjectClass.keys.contains(jsonKey) {
        mapSubObject(key, jsonKey: jsonKey, mappingObjectClass: mappingObjectClass, value: &value)
      }
      
      if mappingElementClass.keys.contains(jsonKey) {
        mapSubObjectArray(key, jsonKey: jsonKey, mappingElementClass: mappingElementClass, value: &value)
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
  
  private func mapSubObjectArray(key: String, jsonKey: String, mappingElementClass: [String: AnyClass], inout value: AnyObject) {
    guard let objClass = mappingElementClass[jsonKey] as? NSObject.Type else {
      fatalError("Reflect error: Sub-model is not a subclass of NSObject")
    }
    guard let subArrayJson = value as? [AnyObject] else {
      debugPrint("Reflect error: Error key: \(key) -- mapping sub-model array without a array json")
      return
    }
    let submodelArray: [NSObject] = subArrayJson.map {
      let submodel = objClass.init()
      if $0 is NSDictionary || $0 is [String: AnyObject] {
        submodel.mapProperty($0)
      } else {
        debugPrint("Reflect error: Error key: \(key) -- mapping sub-model array element without a dictionary json")
      }
      return submodel
    }
    value = submodelArray
  }
  
  private func setPropertyValue(value: AnyObject?, forKey key: String) {
    
    setValue(value, forKey: key)
    
  }
  
  //
  func ergodicObjectKeys() -> [String] {
    var keys = [String]()
    if #available(iOS 8.0, *) {
      let mirror = Mirror(reflecting: self)
      keys = mirror.children.map {$0.label!}
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
  
  private func getMappingReplaceProperty() -> [String: String] {
    var replacePropertyName = [String: String]()
    return getProtocolSetting(&replacePropertyName, aSelector: #selector(TTReflectProtocol.setupMappingReplaceProperty))
  }
  
  private func getMappingIgnorePropertyNames() -> [String] {
    var ignorePropertyNames = [String]()
    return getProtocolSetting(&ignorePropertyNames, aSelector: #selector(TTReflectProtocol.setupMappingIgnorePropertyNames))
  }
  
  private func getMappingObjectClass() -> [String: AnyClass] {
    var mappingObjectClass = [String: AnyClass]()
    return getProtocolSetting(&mappingObjectClass, aSelector: #selector(TTReflectProtocol.setupMappingObjectClass))
  }
  
  private func getMappingElementClass() -> [String: AnyClass] {
    var mappingElementClass = [String: AnyClass]()
    return getProtocolSetting(&mappingElementClass, aSelector: #selector(TTReflectProtocol.setupMappingElementClass))
  }
  
  private func getProtocolSetting<T>(inout emptySetting: T, aSelector: Selector) -> T {
    guard self.respondsToSelector(aSelector) else {return emptySetting}
    let res = self.performSelector(aSelector)
    emptySetting = res.takeUnretainedValue() as! T
    return emptySetting
  }
}
