//
//  TTReflectTests.swift
//  TTReflectTests
//
//  Created by 谢许峰 on 16/1/10.
//  Copyright © 2016年 tifatsubasa. All rights reserved.
//

import XCTest
@testable import TTReflect
import Alamofire

class TTReflectTests: XCTestCase {
  
  func testBook() {
    let bookUrl = NSURL.fileURLWithPath(NSBundle.mainBundle().pathForResource("book", ofType: nil)!)
    let bookData = NSData(contentsOfURL: bookUrl)
    let book = Reflect.model(data: bookData, type: Book.self)
    XCTAssertEqual(book.tt, "满月之夜白鲸现")
    XCTAssertEqual(book.tags.count, 8)
    XCTAssertEqual(book.tags.first?.count, 136)
    XCTAssertNotNil(book.image)
    XCTAssertEqual(book.image, "")
    XCTAssertEqual(book.images.medium, "")
    XCTAssertEqual(book.images.large, "https://img1.doubanio.com/lpic/s1747553.jpg")
    XCTAssertEqual(book.tags.last?.title, "")
    XCTAssertEqual(book.tags.first?.title, "片山恭一")
    XCTAssertNotNil(book.test_null)
  }
  
  func testCast() {
    let castUrl = NSURL.fileURLWithPath(NSBundle.mainBundle().pathForResource("casts", ofType: nil)!)
    let castsData = NSData(contentsOfURL: castUrl)
    let casts = Reflect.modelArray(data: castsData, type: Cast.self)
    XCTAssertEqual(casts.count, 4)
    XCTAssertEqual(casts.first?.alt, "http://movie.douban.com/celebrity/1054395/")
    XCTAssertEqual(casts.last?.avatars.medium, "https://img1.doubanio.com/img/celebrity/medium/42033.jpg")
  }
  
  func testAlamofire() {
     let expectation = expectationWithDescription("Swift Expectations")
    Alamofire.request(.GET, "https://api.douban.com/v2/movie/subject/1764796", parameters: nil)
      .response { request, response, data, error in
//        let json = try! NSJSONSerialization.JSONObjectWithData(data!, options: .MutableContainers)
        let movie = Reflect.model(data: data, type: Movie.self)
        XCTAssertEqual(movie.title, "机器人9号")
        XCTAssertEqual(movie.images.small, "https://img1.doubanio.com/view/movie_poster_cover/ipst/public/p494268647.jpg")
        XCTAssertEqual(movie.subtype, "movie")
        expectation.fulfill()
    }
    waitForExpectationsWithTimeout(10, handler: nil)
  }
}
