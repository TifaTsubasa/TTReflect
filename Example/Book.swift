//
//  Book.swift
//  TTReflect
//
//  Created by 谢许峰 on 16/1/10.
//  Copyright © 2016年 tifatsubasa. All rights reserved.
//

import UIKit

class Book: NSObject {
    var tt: String?
    var pubdate: String?
    var image: String?
    var binding: String?
    var pages: String?
    var alt: String?
    var id: String?
    var publisher: String?
    var summary: String?
    var price: String?
    var images: Images?
    var tags: Array<Tag>?
    
    func setupReplacePropertyName() -> [String : String] {
        return ["title": "tt"]
    }
    
    func setupReplaceObjectClass() -> [String : AnyObject] {
        return ["images": Images.self]
    }
    
    func setupReplaceElementClass() -> [String : AnyObject] {
        return ["tags": Tag.self]
    }
}
