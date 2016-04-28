//
//  Cast.swift
//  TTReflect
//
//  Created by 谢许峰 on 16/1/10.
//  Copyright © 2016年 tifatsubasa. All rights reserved.
//

import UIKit

class Cast: NSObject {
  var alt: String = ""
  var id: String = ""
  var name: String = ""
  var avatars = Images()
  
  func setupReplaceObjectClass() -> [String : String] {
    return ["avatars": "Images"]
  }
}
