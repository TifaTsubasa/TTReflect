//
//  Reflect2.swift
//  TTReflect
//
//  Created by TifaTsubasa on 16/5/27.
//  Copyright © 2016年 tifatsubasa. All rights reserved.
//

import Foundation

public class Reflect2<M: NSObject> {
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
      return Reflect2<M>.mapObject(json: json)
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
public protocol TTReflectProtocol2 {
  optional func setupReplacePropertyName() -> [String: String]
  optional func setupReplaceObjectClass() -> [String: AnyClass]
  optional func setupReplaceElementClass() -> [String: AnyClass]
}

extension NSObject {
  // main function
  private func mapProperty(json: AnyObject) {
    if json is NSNull {
      return
    }
    
    let keys = ergodicObjectKeys()
    let ignoreKeys = ["tt", "image"]
    for key in keys {
      let value = json.valueForKey(key)
      debugPrint(key, value)
      if !ignoreKeys.contains(key) {
        setValue(json.valueForKey(key), forKey: key)
      }
    }
  }
  
  //
  func ergodicObjectKeys() -> [String] {
    var keys = [String]()
    let mirror = Mirror(reflecting: self)
    keys = mirror.children.map { $0.label! }
    return keys
  }
}