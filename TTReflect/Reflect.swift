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
  /**
   map object with json
   
   - returns: special type object
   */
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
      return Reflect<M>.mapObject(json: $0)
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

// MARK: - object map setting protocol
@objc
public protocol TTReflectProtocol {
  optional func setupMappingReplaceProperty() -> [String: String]
  optional func setupMappingObjectClass() -> [String: AnyClass]
  optional func setupMappingElementClass() -> [String: AnyClass]
  optional func setupMappingIgnorePropertyNames() -> [String]
}

// MARK: - private function
extension NSObject: TTReflectProtocol {
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
      guard var value = jsonValue else {continue}
      if value is NSNull {  // ignore null porperty
        debugPrint("Reflect error: The key \(jsonKey) value is \(value)")
        continue
      }
      
      // map sub object
      mapSubObject(key, jsonKey: jsonKey, mappingObjectClass: mappingObjectClass, value: &value)
      
      // map sub array
      mapSubObjectArray(key, jsonKey: jsonKey, mappingElementClass: mappingElementClass, value: &value)
      
      
      setPropertyValue(value, forKey: key)
      
    }
  }
  
  private func mapSubObject(key: String, jsonKey: String, mappingObjectClass: [String: AnyClass], inout value: AnyObject) {
    guard mappingObjectClass.keys.contains(jsonKey) else {return}
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
    guard mappingElementClass.keys.contains(jsonKey) else {return}
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
    let jsonType: AnyClass? = value?.classForCoder
    let objType: AnyClass? = valueForKey(key)?.classForCoder
    guard jsonType != objType else {
      setValue(value, forKey: key)
      return
    }
    
    // convert type
    var transValue: AnyObject?
    let valueTuple = (valueForKey(key), value)
    switch valueTuple {
    case let (objValue as NSNumber, jsonValue as NSString):
      if objValue.isBool { // string -> bool
        if jsonValue == "true" {
          transValue = true
        }
      } else { // string -> number
        if let res = NSNumberFormatter().numberFromString(jsonValue as String) {
          transValue = res
        }
      }
    case let (_ as NSString, jsonValue as NSNumber):
      transValue = String(jsonValue)
    default: break
    }
    
    if let transValue = transValue {
      debugPrint("Reflect warning: The key \(key) have different type value")
      setValue(transValue, forKey: key)
    } else {
      debugPrint("Reflect error: The key \(key) map error type")
    }
  }
  
  //
  func ergodicObjectKeys() -> [String] {
    var keys = [String]()
    if #available(iOS 8.0, *) {
      let mirror = Mirror(reflecting: self)
      if let objectKeys = reflectObjectKeys(mirror) {
        keys = objectKeys
      }
    } else {
      keys = getObjectKeys(self.classForCoder)
    }
    return keys
  }
  
  func reflectObjectKeys(mirror: Mirror?) -> [String]? { // iOS8+
    guard let mirror = mirror else { return nil }
    var keys = mirror.children.flatMap {$0.label}
    if mirror.superclassMirror()?.subjectType != NSObject.self {
      if let subKeys = reflectObjectKeys(mirror.superclassMirror()) {
        keys.appendContentsOf(subKeys)
      }
    }
    return keys
  }
  
  func getObjectKeys(cls: AnyClass) -> [String] { // iOS 7
    var keys = [String]()
    var propNum: UInt32 = 0
    let propList = class_copyPropertyList(cls, &propNum)
    for index in 0..<numericCast(propNum) {
      let prop: objc_property_t = propList[index]
      keys.append(String(UTF8String: property_getName(prop))!)
    }
    if class_getSuperclass(cls) != NSObject.self {
      keys.appendContentsOf(getObjectKeys(class_getSuperclass(cls)))
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


// MARK: - NSNumber: Comparable

extension NSNumber {
  var isBool:Bool {
    get {
      let trueNumber = NSNumber(bool: true)
      let falseNumber = NSNumber(bool: false)
      let trueObjCType = String.fromCString(trueNumber.objCType)
      let falseObjCType = String.fromCString(falseNumber.objCType)
      let objCType = String.fromCString(self.objCType)
      if (self.compare(trueNumber) == NSComparisonResult.OrderedSame && objCType == trueObjCType)
        || (self.compare(falseNumber) == NSComparisonResult.OrderedSame && objCType == falseObjCType){
        return true
      } else {
        return false
      }
    }
  }
}
