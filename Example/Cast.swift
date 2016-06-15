//
//  Cast.swift
//  TTReflect
//
//  Created by 谢许峰 on 16/1/10.
//  Copyright © 2016年 tifatsubasa. All rights reserved.
//

import UIKit

class ACast: NSObject {
  var alt: String = ""
}

class BCast: ACast {
  var id: String = ""
}

class CCast: BCast {
  var name: String = ""
}

class Cast: CCast {
  var avatars = Images()
  
  func setupMappingObjectClass() -> [String : AnyClass] {
    return ["avatars": Images.self]
  }
}
