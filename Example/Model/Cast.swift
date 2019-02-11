//
//  Cast.swift
//  TTReflect
//
//  Created by 谢许峰 on 16/1/10.
//  Copyright © 2016年 tifatsubasa. All rights reserved.
//

import UIKit

@objcMembers class ACast: NSObject {
  var alt: String = ""
}

@objcMembers class BCast: ACast {
  var id: String = ""
}

@objcMembers class CCast: BCast {
  var name: String = ""
}

@objcMembers class Cast: CCast {
  var avatars = Images()
  
  func setupMappingObjectClass() -> [String : AnyClass] {
    return ["avatars": Images.self]
  }
}
