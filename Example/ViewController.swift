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
        
        let bookPath = NSBundle.mainBundle().pathForResource("book", ofType: nil)
        print("", bookPath)
        let url = NSURL.fileURLWithPath(bookPath!)
        let bookData = NSData(contentsOfURL: url)
        print(bookData)
//        let book = Book()
//        book.replacePropertyName = []
        let book = Reflect.model(bookData, type: Book.self)
        print(book)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

