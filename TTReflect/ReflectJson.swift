//
//  ReflectJson.swift
//  TTReflect
//
//  Created by Tsuf on 2017/12/15.
//  Copyright © 2017年 tifatsubasa. All rights reserved.
//

import UIKit

protocol ReflectJson {
  func toJSONModel() -> AnyObject?
  func toJSONString() -> String?
}

extension ReflectJson {
  func getMirrorKeyValues(_ mirror: Mirror?) -> [String: Any] { // iOS8+
    var keyValues = [String: Any]()
    guard let mirror = mirror else { return keyValues }
    for case let (label?, value) in mirror.children {
      keyValues[label] = value
    }
    if mirror.superclassMirror?.subjectType != NSObject.self {
      getMirrorKeyValues(mirror.superclassMirror).forEach({ (key, value) in
        keyValues[key] = value
      })
    }
    return keyValues
  }
  
  //将数据转成可用的JSON模型
  func toJSONModel() -> AnyObject? {
    let replacePropertys = (self as? TTReflectProtocol)?.setupMappingReplaceProperty?() ?? [:]
    
    let mirror = Mirror(reflecting: self)
    if mirror.children.count > 0 {
      var result: [String: AnyObject] = [:]
      for case let (label?, value) in mirror.children {
        let sourceLabel = replacePropertys.keys.contains(label) ? replacePropertys[label]! : label
        debugPrint("source label: ", sourceLabel)
        if let jsonValue = value as? ReflectJson {
          if let hasResult = jsonValue.toJSONModel() {
//            debugPrint("has result: ", label, "-", hasResult)
            result[sourceLabel] = hasResult
          } else {
            let valueMirror = Mirror(reflecting: value)
            if valueMirror.superclassMirror?.subjectType != NSObject.self {
//              debugPrint("not object: ", label, "-", value)
              result[sourceLabel] = value as AnyObject
            }
          }
        }
      }
      return result as AnyObject
    }
    return nil
  }
  
  //将数据转成JSON字符串
  func toJSONString() -> String? {
    guard let jsonModel = self.toJSONModel() else {
      return ""
    }
//    debugPrint(jsonModel)
    //利用OC的json库转换成Data，
    let data = try? JSONSerialization.data(withJSONObject: jsonModel,
                                           options: [])
    //Data转换成String打印输出
    let str = String(data: data!, encoding: .utf8)
    return str
  }
}

extension NSObject: ReflectJson { }

extension String: ReflectJson { }
extension Int: ReflectJson { }
extension Double: ReflectJson { }
extension Bool: ReflectJson { }
extension Dictionary: ReflectJson { }
//扩展Array，格式化输出
extension Array: ReflectJson {
  //将数据转成可用的JSON模型
  func toJSONModel() -> AnyObject? {
    var result: [AnyObject] = []
    for value in self {
      if let jsonValue = value as? ReflectJson , let jsonModel = jsonValue.toJSONModel(){
        result.append(jsonModel)
      }
    }
    return result as AnyObject
  }
}
