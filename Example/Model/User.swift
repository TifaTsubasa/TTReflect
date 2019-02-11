//
//  User.swift
//  TTReflect
//
//  Created by 谢许峰 on 16/1/11.
//  Copyright © 2016年 tifatsubasa. All rights reserved.
//

import UIKit

@objcMembers class User: NSObject {
  var avatar: String = ""
  var avatar_large: String = ""
  var link: String = ""
  var desc: String = ""
  
  func setupMappingReplaceProperty() -> [String : String] {
    return ["description": "desc"]
  }
}
