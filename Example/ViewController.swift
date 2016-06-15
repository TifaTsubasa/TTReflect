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
import SwiftyJSON

class ViewController: UIViewController {
  
  func injected() {
    self.viewDidLoad()
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
//    let home = Reflect<Item>.mapObjects("Home")
//    debugPrint(home)
    
    
    let bookUrl = NSURL.fileURLWithPath(NSBundle.mainBundle().pathForResource("book", ofType: nil)!)
    let bookData = NSData(contentsOfURL: bookUrl)
    let json = try! NSJSONSerialization.JSONObjectWithData(bookData!, options: NSJSONReadingOptions.AllowFragments)
    let book = Reflect<Book>.mapObject(json: json)
//    let books = Reflect2<[Book]>.mapping(json: json)
//    let books = Reflect<Book>.mapObjects(json: json)
    let tag = book.tags.first
    debugPrint(book)
    
    let castUrl = NSURL.fileURLWithPath(NSBundle.mainBundle().pathForResource("casts", ofType: nil)!)
    let castsData = NSData(contentsOfURL: castUrl)
    let castsJson = try! NSJSONSerialization.JSONObjectWithData(castsData!, options: .AllowFragments)
    let castsJ = JSON(data: castsData!)
    let casts = Reflect<Cast>.mapObjects(json: castsJ.rawValue)
    let cast = casts.first
    debugPrint(casts)
//    self.useAFNetworking()
    useAlamofire()
  }
  
  func useAFNetworking() {
    let manager = AFHTTPRequestOperationManager()
    manager.GET("https://api.douban.com/v2/movie/subject/1764796", parameters: nil, success: { (operation, responseData) -> Void in
      let movie = Reflect<Movie>.mapObjects(json: responseData)
      print(movie)
      }, failure: nil)
  }
  
  func useAlamofire() {
    request(.GET, "https://api.douban.com/v2/movie/subject/1764796", parameters: nil, encoding: .URL, headers: nil)
      .response { request, response, data, error in
        
        
        let j = try! NSJSONSerialization.JSONObjectWithData(data!, options: .AllowFragments)
        let json = JSON(data: data!)
//        debugPrint(json)
        let movie = Reflect<Movie>.mapObject(json: json.rawValue)
        debugPrint(movie)
    }
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  
}

