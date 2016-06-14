//
//  Book.swift
//  TTReflect
//
//  Created by 谢许峰 on 16/1/10.
//  Copyright © 2016年 tifatsubasa. All rights reserved.
//

import UIKit

class TTNull: NSObject {
  
}

class Book: NSObject {
  var tt: String = ""
  var pubdate: String = ""
  var image: String = ""
  var binding: String = ""
  var pages = 0
  var alt: String = ""
  var id: String = ""
  var publisher: String = ""
  var summary: String = ""
  var price: String = ""
  var secretly: Bool = false
  var images = Images()
  var tags = [Tag]()
  var test_null = TTNull()
  
  func setupMappingReplaceProperty() -> [String : String] {
    return ["tt": "title"]
  }
  
//  func setupMappingIgnorePropertyNames() -> [String] {
//    return ["tt"]
//  }
  
  func setupMappingObjectClass() -> [String : AnyClass] {
    return ["images": Images.self, "test_null": TTNull.self]
  }
  
//  func setupReplaceObjectClass() -> [String : String] {
//    return ["images": "Images", "test_null": "TTNull"]
//  }
  
  func setupReplaceElementClass() -> [String : String] {
    return ["tags": "Tag"]
  }
}
