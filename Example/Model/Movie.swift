//
//  Movie.swift
//  TTReflect
//
//  Created by TifaTsubasa on 16/1/11.
//  Copyright © 2016年 tifatsubasa. All rights reserved.
//

import UIKit

class Movie: NSObject {
  var reviews_count = 0
  var wish_count = 0
  var collect_count = 0
  var douban_site = ""
  var mobile_url = ""
  var share_url = ""
  var title = ""
  var id = ""
  var subtype: String = ""
  var images = Images()
  
  func setupMappingObjectClass() -> [String : AnyClass] {
    return ["images": Images.self]
  }
}
