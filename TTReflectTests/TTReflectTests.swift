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
import SwiftyJSON

class TTReflectTests: XCTestCase {
  
  func assertBook(_ book: Book) {
    XCTAssertEqual(book.tt, "满月之夜白鲸现")
    XCTAssertEqual(book.tags.count, 8)
    XCTAssertEqual(book.tags.first?.count, 136)
    XCTAssertNotNil(book.image)
    XCTAssertEqual(book.image, "")
    XCTAssertEqual(book.imgs.medium, "")
    XCTAssertEqual(book.imgs.large, "https://img1.doubanio.com/lpic/s1747553.jpg")
    XCTAssertEqual(book.tags.last?.title, "")
    XCTAssertEqual(book.tags.first?.title, "片山恭一")
    XCTAssertNotNil(book.test_null)
  }
  
  func assertCast(_ casts: [Cast]) {
    XCTAssertEqual(casts.count, 4)
    XCTAssertEqual(casts.first?.alt, "http://movie.douban.com/celebrity/1054395/")
    XCTAssertEqual(casts.last?.avatars.medium, "https://img1.doubanio.com/img/celebrity/medium/42033.jpg")
  }
  
  func assertConvert(_ convert: Convert) {
    XCTAssertEqual(convert.scns, 42.3)
    XCTAssertEqual(convert.ncss, "23.98")
    XCTAssertEqual(convert.bcss, "1")
    XCTAssertEqual(convert.scbs, true)
    XCTAssertEqual(convert.scbe, false)
  }
  
  func testConvert() {
    let convertUrl = URL(fileURLWithPath: Bundle.main.path(forResource: "convert", ofType: nil)!)
    let convertData = try? Data(contentsOf: convertUrl)
    let convert = Reflect<Convert>.mapObject(data: convertData)
    assertConvert(convert)
  }
  
  func testConvertWithModel() {
    let convertUrl = URL(fileURLWithPath: Bundle.main.path(forResource: "convert", ofType: nil)!)
    let convertData = try? Data(contentsOf: convertUrl)
    let oldScns = 33.3
    let oldConvert = Convert()
    oldConvert.scns = oldScns
    let convert = Reflect<Convert>.mapObject(data: convertData)
    XCTAssertNotEqual(convert.scns, oldScns)
    let tranformJsonConvert = Reflect<Convert>.mapObject(data: convert.toJSONString()?.data(using: .utf8))
    assertConvert(convert)
    assertConvert(tranformJsonConvert)
  }
  
  func testBookData() {
    let bookUrl = URL(fileURLWithPath: Bundle.main.path(forResource: "book", ofType: nil)!)
    let bookData = try? Data(contentsOf: bookUrl)
    let book = Reflect<Book>.mapObject(data: bookData)
    assertBook(book)
    assertBook(Reflect<Book>.mapObject(data: book.toJSONString()?.data(using: .utf8)))
  }
  
  func testBookDataWithModel() {
    let bookUrl = URL(fileURLWithPath: Bundle.main.path(forResource: "book", ofType: nil)!)
    let bookData = try? Data(contentsOf: bookUrl)
    let oldId = "old book"
    let oldBook = Book()
    oldBook.id = oldId
    let newBook = Reflect<Book>.mapObject(data: bookData, override: oldBook)
    XCTAssertNotEqual(newBook.id, oldId)
    assertBook(newBook)
    assertBook(Reflect<Book>.mapObject(data: newBook.toJSONString()?.data(using: .utf8)))
  }
  
  func testBookJson() {
    let bookUrl = URL(fileURLWithPath: Bundle.main.path(forResource: "book", ofType: nil)!)
    let bookData = try? Data(contentsOf: bookUrl)
    let json = try! JSONSerialization.jsonObject(with: bookData!, options: .mutableContainers)
    let book = Reflect<Book>.mapObject(json: json)
    assertBook(book)
  }
  
  func testCastData() {
    let castUrl = URL(fileURLWithPath: Bundle.main.path(forResource: "casts", ofType: nil)!)
    let castsData = try? Data(contentsOf: castUrl)
    let casts = Reflect<Cast>.mapObjects(data: castsData)
    let tranformJsonCasts = Reflect<Cast>.mapObjects(data: casts.toJSONString()?.data(using: .utf8))
    debugPrint(casts, tranformJsonCasts)
    debugPrint(casts, tranformJsonCasts)
    assertCast(casts)
    assertCast(tranformJsonCasts)
  }
  
  func testCastJson() {
    let castUrl = URL(fileURLWithPath: Bundle.main.path(forResource: "casts", ofType: nil)!)
    let castsData = try? Data(contentsOf: castUrl)
    let castsJson = try! JSONSerialization.jsonObject(with: castsData!, options: .mutableContainers)
    let casts = Reflect<Cast>.mapObjects(json: castsJson)
    assertCast(casts)
  }
  
  func testAlamofire() {
    let expectation = self.expectation(description: "Alamofire request")
    Alamofire.request("https://api.douban.com/v2/movie/subject/1764796", method: .get, parameters: nil, encoding: URLEncoding.default, headers: nil).response { response in
      let data = response.data
      let json = JSON(data: data!)
      debugPrint(json)
      let movie = Reflect<Movie>.mapObject(json: json.rawValue)
      XCTAssertEqual(movie.title, "机器人9号")
      XCTAssertEqual(movie.subtype, "movie")
      expectation.fulfill()
    }
    waitForExpectations(timeout: 10, handler: nil)
  }
  
  func testAlamofireWithModel() {
    let expectation = self.expectation(description: "Alamofire request with model")
    Alamofire.request("https://api.douban.com/v2/movie/subject/1764796", method: .get, parameters: nil, encoding: URLEncoding.default, headers: nil).response { response in
      let data = response.data
      let json = JSON(data: data!)
      debugPrint(json)
      let oldMovie = Movie()
      let oldMovieTitle = "old movie"
      oldMovie.title = oldMovieTitle
      let newMovie = Reflect<Movie>.mapObject(json: json.rawValue, override: oldMovie)
      XCTAssertNotEqual(newMovie.title, oldMovieTitle)
      XCTAssertEqual(newMovie.title, "机器人9号")
      XCTAssertEqual(newMovie.subtype, "movie")
      expectation.fulfill()
    }
    waitForExpectations(timeout: 10, handler: nil)
  }
  
  func testAlamofireObjects() {
    let expectation = self.expectation(description: "Alamofire objects request")
    Alamofire.request("https://api.douban.com/v2/movie/in_theaters", method: .get, parameters: nil, encoding: URLEncoding.default, headers: nil).response { response in
      let data = response.data
      let json = JSON(data: data!)
      let movie = Reflect<Movie>.mapObjects(json: json["subjects"].rawValue)
      XCTAssertNotEqual(movie.first?.title, "")
      expectation.fulfill()
    }
    waitForExpectations(timeout: 15, handler: nil)
  }
}
