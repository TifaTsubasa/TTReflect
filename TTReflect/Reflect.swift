//
//  Reflect.swift
//  TTReflect
//
//  Created by TifaTsubasa on 16/5/27.
//  Copyright © 2016年 tifatsubasa. All rights reserved.
//

import Foundation

open class Reflect<M: NSObject> {
  
  // MARK: - reflect with json
  /**
   map object with json
   
   - returns: special type object
   */
  
  /// map object with json
  ///
  /// - Parameters:
  ///   - json: json
  ///   - model: refactor the model, keep old value when json without new property
  /// - Returns: return model as same as override model
  public static func mapObject(json: Any?, override model: M = M()) -> M  {
    guard let json = json else { return model }
    guard json is NSDictionary || json is [String: AnyObject] else {
      debugPrint("Reflect error: Mapping model without a dictionary json")
      return model
    }
    model.mapProperty(json)
    return model
  }
  
  public static func mapObjects(json: Any?) -> [M] {
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
  
  /// map object with json
  ///
  /// - Parameters:
  ///   - data: json data
  ///   - model: refactor the model, keep old value when json without new property
  /// - Returns: return model as same as override model
  public static func mapObject(data: Data?, override model: M = M()) -> M {
    guard let data = data else { return model }
    do {
      let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers)
      return Reflect<M>.mapObject(json: json as AnyObject?, override: model)
    } catch {
      debugPrint("Serializat json error: \(error)")
    }
    return model
  }
  
  public static func mapObjects(data: Data?) -> [M] {
    guard let data = data else { return [M]() }
    do {
      let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers)
      return Reflect<M>.mapObjects(json: json as AnyObject?)
    } catch {
      debugPrint("Serializat json error: \(error)")
    }
    return [M]()
  }
  
  // MARK: - reflect with plist name
  public static func mapObject(_ plistName: String?, override model: M = M()) -> M {
    let plistPath = Bundle.main.path(forResource: plistName, ofType: "plist")
    guard let path = plistPath else {
      debugPrint("Reflect error: Error plist name")
      return model
    }
    let json = NSDictionary(contentsOfFile: path)
    return Reflect<M>.mapObject(json: json, override: model)
  }
  
  public static func mapObjects(_ plistName: String?) -> [M] {
    let plistPath = Bundle.main.path(forResource: plistName, ofType: "plist")
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
  @objc optional func setupMappingReplaceProperty() -> [String: String]
  @objc optional func setupMappingObjectClass() -> [String: AnyClass]
  @objc optional func setupMappingElementClass() -> [String: AnyClass]
  @objc optional func setupMappingIgnorePropertyNames() -> [String]
}

// MARK: - private function
extension NSObject: TTReflectProtocol {
  // main function
  fileprivate func mapProperty(_ json: Any) {
    if json is NSNull { return }
    
    // mapping setting
    let replacePropertyName = self.getMappingReplaceProperty()
    let ignorePropertyNames = self.getMappingIgnorePropertyNames()
    let mappingObjectClass = self.getMappingObjectClass()
    let mappingElementClass = self.getMappingElementClass()
    
    let keys = ergodicObjectKeys()
    for key in keys {
      let jsonKey = replacePropertyName[key] ?? key
      let jsonValue = (json as AnyObject).value(forKey: jsonKey)
      
      guard !ignorePropertyNames.contains(key) else {continue}  // ignore property
      guard let value = jsonValue else {continue}
      if value is NSNull {  // ignore null porperty
        debugPrint("Reflect error: The key \(jsonKey) value is \(value)")
        continue
      }
      
      setPropertyValue(value as AnyObject, forKey: key)
      // map sub object
      if let trackObject = mapSubObject(key, jsonKey: jsonKey, mappingObjectClass: mappingObjectClass, value: value as AnyObject){
        setValue(trackObject, forKey: key)
      }
      
      // map sub array
      if let trackObjects = mapSubObjectArray(key, jsonKey: jsonKey, mappingElementClass: mappingElementClass, value: value as AnyObject) {
        setValue(trackObjects, forKey: key)
      }
    }
  }
  
  fileprivate func mapSubObject(_ key: String, jsonKey: String, mappingObjectClass: [String: AnyClass], value: AnyObject) -> AnyObject? {
    guard mappingObjectClass.keys.contains(jsonKey) else {return nil}
    guard let objClass = mappingObjectClass[jsonKey] as? NSObject.Type else {
      fatalError("Reflect error: Sub-model is not a subclass of NSObject")
    }
    let model = objClass.init()
    guard value is NSDictionary || value is [String: AnyObject] else {
      debugPrint("Reflect error: Error key: \(key) -- mapping sub-model without a dictionary json")
      return nil
    }
    model.mapProperty(value)
    return model
  }
  
  fileprivate func mapSubObjectArray(_ key: String, jsonKey: String, mappingElementClass: [String: AnyClass], value: AnyObject) -> AnyObject? {
    guard mappingElementClass.keys.contains(jsonKey) else {return nil}
    guard let objClass = mappingElementClass[jsonKey] as? NSObject.Type else {
      fatalError("Reflect error: Sub-model is not a subclass of NSObject")
    }
    guard let subArrayJson = value as? [AnyObject] else {
      debugPrint("Reflect error: Error key: \(key) -- mapping sub-model array without a array json")
      return nil
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
    return submodelArray as AnyObject
  }
  
  fileprivate func setPropertyValue(_ value: AnyObject?, forKey key: String) {
    // convert type
    var transFlag: Bool?
    
    var transValue: AnyObject?
//    let vvalue = self.value(forKeyPath: key)
//    
//    print("--- \(vvalue)")
    let valueTuple = (self.value(forKey: key), value)
    switch valueTuple {
    case let (objValue as NSNumber, jsonValue as NSString):
      transFlag = false
      if objValue.isBool { // string -> bool
        if jsonValue == "true" {
          transValue = true as AnyObject?
          transFlag = true
        }
      } else { // string -> number
        if let res = NumberFormatter().number(from: jsonValue as String) {
          transValue = res
          transFlag = true
        }
      }
    case let (_ as NSString, jsonValue as NSNumber):
      transValue = "\(jsonValue)" as AnyObject?
      transFlag = true
    default:
      setValue(value, forKey: key)
    }
    
    if let transFlag = transFlag {
      if transFlag {
        debugPrint("Reflect warning: The key \(key) have different type value")
        setValue(transValue, forKey: key)
      } else {
        debugPrint("Reflect error: The key \(key) map error type")
      }
    }
  }
  
  //
  func ergodicObjectKeys() -> [String] {
    var keys = [String]()
    let mirror = Mirror(reflecting: self)
    if let objectKeys = reflectObjectKeys(mirror) {
      keys = objectKeys
    }
    return keys
  }
  
  func reflectObjectKeys(_ mirror: Mirror?) -> [String]? { // iOS8+
    guard let mirror = mirror else { return nil }
    var keys = mirror.children.compactMap {$0.label}
    if mirror.superclassMirror?.subjectType != NSObject.self {
      if let subKeys = reflectObjectKeys(mirror.superclassMirror) {
        keys.append(contentsOf: subKeys)
      }
    }
    return keys
  }
  
//  func getObjectKeys(_ cls: AnyClass) -> [String] { // iOS 7
//    var keys = [String]()
//    var propNum: UInt32 = 0
//    let propList = class_copyPropertyList(cls, &propNum)
//    for index in 0..<numericCast(propNum) {
//      let prop: objc_property_t = propList![index]!
//      keys.append(String(validatingUTF8: property_getName(prop))!)
//    }
//    if class_getSuperclass(cls) != NSObject.self {
//      keys.append(contentsOf: getObjectKeys(class_getSuperclass(cls)))
//    }
//    return keys
//  }
  
  fileprivate func getMappingReplaceProperty() -> [String: String] {
    var replacePropertyName = [String: String]()
    return getProtocolSetting(&replacePropertyName, aSelector: #selector(TTReflectProtocol.setupMappingReplaceProperty))
  }
  
  fileprivate func getMappingIgnorePropertyNames() -> [String] {
    var ignorePropertyNames = [String]()
    return getProtocolSetting(&ignorePropertyNames, aSelector: #selector(TTReflectProtocol.setupMappingIgnorePropertyNames))
  }
  
  fileprivate func getMappingObjectClass() -> [String: AnyClass] {
    var mappingObjectClass = [String: AnyClass]()
    return getProtocolSetting(&mappingObjectClass, aSelector: #selector(TTReflectProtocol.setupMappingObjectClass))
  }
  
  fileprivate func getMappingElementClass() -> [String: AnyClass] {
    var mappingElementClass = [String: AnyClass]()
    return getProtocolSetting(&mappingElementClass, aSelector: #selector(TTReflectProtocol.setupMappingElementClass))
  }
  
  fileprivate func getProtocolSetting<T>(_ emptySetting: inout T, aSelector: Selector) -> T {
    guard self.responds(to: aSelector) else {return emptySetting}
    let res = self.perform(aSelector)
    emptySetting = res?.takeUnretainedValue() as! T
    return emptySetting
  }
}


// MARK: - NSNumber: Comparable
extension NSNumber {
  var isBool:Bool {
    get {
      let trueNumber = NSNumber(value: true as Bool)
      let falseNumber = NSNumber(value: false as Bool)
      let trueObjCType = String(cString: trueNumber.objCType)
      let falseObjCType = String(cString: falseNumber.objCType)
      let objCType = String(cString: self.objCType)
      if (self.compare(trueNumber) == ComparisonResult.orderedSame && objCType == trueObjCType)
        || (self.compare(falseNumber) == ComparisonResult.orderedSame && objCType == falseObjCType){
        return true
      } else {
        return false
      }
    }
  }
}
