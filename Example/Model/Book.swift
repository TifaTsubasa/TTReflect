//
//  Book.swift
//  TTReflect
//
//  Created by 谢许峰 on 16/1/10.
//  Copyright © 2016年 tifatsubasa. All rights reserved.
//

import UIKit

@objcMembers class TTNull: NSObject {
  
}

@objcMembers class Book: NSObject {
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
  var imgs = Images()
  var tags = [Tag]()
  var test_null = TTNull()
  
  func setupMappingReplaceProperty() -> [String : String] {
    return ["tt": "title", "imgs": "images"]
  }
  
  func setupMappingObjectClass() -> [String : AnyClass] {
    return ["images": Images.self, "test_null": TTNull.self]
  }

  func setupMappingElementClass() -> [String : AnyClass] {
    return ["tags": Tag.self]
  }
}

// MARK: - Swift 4 JSONEncoder
struct NullStruct: Codable {
  
}

struct BookStruct: Codable {
  let tt: String
  
  let pubdate: String
  let binding: String
  let pages: Int
  let alt: String
  let id: String
  let publisher: String
  let summary: String
  let price: String
  let secretly: String
  let imgs: ImagesStruct
  let tags: [TagStruct]
  
  enum CodingKeys : String, CodingKey{
    case tt = "title"
    case pubdate
    case binding
    case pages
    case alt
    case id
    case publisher
    case summary
    case price
    case secretly
    case imgs = "images"
    case tags
  }
  
  struct ImagesStruct: Codable {
    let small: String
    let large: String
    let medium: String?
  }

  struct TagStruct: Codable {
    let count: Int
    let name: String?
    let title: String?
  }

}
