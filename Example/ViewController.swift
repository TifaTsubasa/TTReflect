//
//  ViewController.swift
//  TTReflect
//
//  Created by 谢许峰 on 16/1/10.
//  Copyright © 2016年 tifatsubasa. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let bookUrl = NSURL.fileURLWithPath(NSBundle.mainBundle().pathForResource("book", ofType: nil)!)
        let bookData = NSData(contentsOfURL: bookUrl)
        
        let castUrl = NSURL.fileURLWithPath(NSBundle.mainBundle().pathForResource("casts", ofType: nil)!)
        let castsData = NSData(contentsOfURL: castUrl)
//        print(bookData)
//        let book = Book()
//        book.replacePropertyName = []
        print(NSDate())
        let casts = Reflect.modelArray(castsData, type: Cast.self)
//            print(casts)
        let book = Reflect.model(bookData, type: Book.self)
//        let casts = Reflect.modelArray(<#T##json: AnyObject?##AnyObject?#>, type: <#T##T.Type#>)
        
        print(NSDate())
//        print(book?.tags?[0].count)
        let tag = book?.tags?[1]
        tag?.count
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

