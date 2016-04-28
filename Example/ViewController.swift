//
//  ViewController.swift
//  TTReflect
//
//  Created by 谢许峰 on 16/1/10.
//  Copyright © 2016年 tifatsubasa. All rights reserved.
//

import UIKit
import AFNetworking
import Alamofire

class ViewController: UIViewController {
  
  func injected() {
    self.viewDidLoad()
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    let home = Reflect.modelArray("Home", type: Item.self)
    
    self.useAFNetworking()
  }
  
  func useAFNetworking() {
    let manager = AFHTTPRequestOperationManager()
    manager.GET("https://api.douban.com/v2/movie/subject/1764796", parameters: nil, success: { (operation, responseData) -> Void in
      let movie = Reflect.model(json: responseData, type: Movie.self)
      print(movie)
      }, failure: nil)
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  
}

