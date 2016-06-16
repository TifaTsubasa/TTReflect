
# TTReflect
![Alt text](http://7xq01t.com1.z0.glb.clouddn.com/TTReflect_cover.png)
#### json convert to object in **Swift**
[![CocoaPods Compatible](https://img.shields.io/cocoapods/v/TTReflect.svg)](https://img.shields.io/cocoapods/v/TTReflect.svg)
[![Platform](https://img.shields.io/cocoapods/p/TTReflect.svg?style=flat)](http://cocoadocs.org/docsets/TTReflect)

[中文说明请戳我](https://github.com/TifaTsubasa/TTReflect/blob/master/README-zh.md)
### Update Log

#### 2.0.0
* new Api, more swift
* support model inheritance
* auto convert when json and property of different types

> 2.0 override api, can not use with previous version

### Installation
#### iOS 7
##### Manually
drop `TTReflect.swift` to your project

#### iOS 8+
##### CocoaPods

```
platform :ios, '8.0'
use_frameworks!
pod 'TTReflect', '~> 2.0'
```

import lib
```
import TTReflect
```
=======


### Usage
#### Model requirements

```
class Tag: NSObject {
    var count: Int = 0
    var name: String = ""
    var title: String = ""
    var isOpen: Bool = false
}
```

> Commend evey property have default value, will show model with nothing, not crash with nil

**1.Your model should be subclass of NSObject**

**2.Comend property have default value**

> Various models defined way:  [TEST MODEL](https://github.com/TifaTsubasa/TTReflect/tree/master/Example/Model)

#### Main function
```
// e.g. Tag Model
// convert json to object
let tag = Reflect<Tag>.mapObject(json: json)
// convert data to object
let tag = Reflect<Tag>.mapObject(data: data)
// convert json to object array
let tags = Reflect<Tag>.mapObjects(json: json)
// convert data to object array
let tags = Reflect<Tag>.mapObjects(data: data)
```

#### Example
##### Dictionary -> Model

###### Specifies json/data and model type

```
let book = Reflect<Book>.mapObject(json: json)
let book = Reflect<Book>.mapObject(data: data)
```
![Alt text](http://7xq01t.com1.z0.glb.clouddn.com/TTReflect_mapObject.png)

##### JsonArray -> ModelArray
###### Specifies json/data and array element type
```
let casts = Reflect<Cast>.mapObjects(json: json)
let casts = Reflect<Cast>.mapObjects(data: data)
```
![Alt text](http://7xq01t.com1.z0.glb.clouddn.com/TTReflect_mapObjects.png)



=======

###Protocol function
#### 1.Replace attribute
json["title"] reflect model.tt

```
func setupMappingReplaceProperty() -> [String : String] {
    return ["tt": "title"]
}
```

#### 2.Model of embedding model
Specifies subclass type and key in json

```
func setupMappingObjectClass() -> [String : AnyClass] {
  return ["images": Images.self]
}
```

#### 3.Model array embedded in model
Specifies model array element type and key in json

```
func setupMappingElementClass() -> [String : AnyClass] {
  return ["tags": Tag.self]
}
```

#### 4.Ignore model property
Specifies property names

```
func setupMappingIgnorePropertyNames() -> [String] {
  return ["tags"]
}
```

#### Full model example
```
class TTNull: NSObject {
  
}

class Book: NSObject {
  var tt: String = ""
  var pubdate: String = ""
  var image: String = ""
  var binding: String = ""
  var pages = 0
  var alt: String = ""
  var id: String = ""
  var publisher: String = ""
  var summary: String = ""
  var price: String = ""
  var secretly: Bool = false
  var imgs = Images()
  var tags = [Tag]()
  var test_null = TTNull()
  
  func setupMappingReplaceProperty() -> [String : String] {
    return ["tt": "title", "imgs": "images"]
  }
  
  func setupMappingObjectClass() -> [String : AnyClass] {
    return ["images": Images.self, "test_null": TTNull.self]
  }

  func setupMappingElementClass() -> [String : AnyClass] {
    return ["tags": Tag.self]
  }
}
```

#### Full reflect
![Alt text](http://7xq01t.com1.z0.glb.clouddn.com/TTReflect_fullmap.png)



=======
### Help

Sorry for my poor english，I need your help 😢
1.Please commit issues when you encounter bug or expect new function, thanks!

2.Please pull request when you have good idea ^ ^

**E-mail: tifatsubasa@163.com**
