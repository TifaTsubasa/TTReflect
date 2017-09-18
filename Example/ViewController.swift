//
//  ViewController.swift
//  TTReflect
//
//  Created by 谢许峰 on 16/1/10.
//  Copyright © 2016年 tifatsubasa. All rights reserved.
//

import UIKit

import Alamofire
import SwiftyJSON
import AFNetworking

class ViewController: UIViewController {
  
  func injected() {
    self.viewDidLoad()
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    //    let home = Reflect<Item>.mapObjects("Home")
    //    debugPrint(home)
    
    
    let bookUrl = URL(fileURLWithPath: Bundle.main.path(forResource: "book", ofType: nil)!)
    let bookData = try? Data(contentsOf: bookUrl)
    let json = try! JSONSerialization.jsonObject(with: bookData!, options: JSONSerialization.ReadingOptions.allowFragments)
    let book = Book()
    
        let b = Reflect<Book>.mapObject(json: json, override: book)
    //    let books = Reflect2<[Book]>.mapping(json: json)
    //    let books = Reflect<Book>.mapObjects(json: json)
    //    let tag = book.tags.first
    //    debugPrint(book)
    
    let castUrl = URL(fileURLWithPath: Bundle.main.path(forResource: "casts", ofType: nil)!)
    let castsData = try? Data(contentsOf: castUrl)
    let castsJson = try! JSONSerialization.jsonObject(with: castsData!, options: .allowFragments)
    let castsJ = JSON(data: castsData!)
    let casts = Reflect<Cast>.mapObjects(json: castsJ.rawValue as AnyObject)
    let cast = casts.first
    debugPrint(casts)
    //    self.useAFNetworking()
    useAlamofire()
  }
  
  func useAFNetworking() {
    
    let manager = AFHTTPRequestOperationManager()
    manager.get("https://api.douban.com/v2/movie/subject/1764796", parameters: nil, success: { (operation, responseData) -> Void in
      let movie = Reflect<Movie>.mapObjects(json: responseData as AnyObject)
      print(movie)
    }, failure: nil)
  }
  
  func useAlamofire() {
    Alamofire.request("https://api.douban.com/v2/movie/subject/1764796", method: .get, parameters: nil, encoding: URLEncoding.default, headers: nil).response { response in
      
      let data = response.data
      let j = try! JSONSerialization.jsonObject(with: data!, options: .allowFragments)
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

