//
//  Item.swift
//  TTReflect
//
//  Created by 谢许峰 on 16/1/11.
//  Copyright © 2016年 tifatsubasa. All rights reserved.
//

import UIKit

@objcMembers class Item: NSObject {
    var username: String = ""
    var index: Int = 0
    var type: String = ""
    var users = [User]()
  
  func setupMappingElementClass() -> [String : AnyClass] {
    return ["users": User.self]
  }
}
