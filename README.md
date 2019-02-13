
# TTReflect
![Alt text](http://images.upmer.com/TTReflect_cover.png)
#### swift版 json转model 框架
[![CocoaPods Compatible](https://img.shields.io/cocoapods/v/TTReflect.svg)](https://img.shields.io/cocoapods/v/TTReflect.svg)
[![Platform](https://img.shields.io/cocoapods/p/TTReflect.svg?style=flat)](http://cocoadocs.org/docsets/TTReflect)

### 适配 Swift 4+ (iOS 8+)
1. 切换到`master`分支, 手动拖拽`Reflect.swift`文件到你的项目中

2. CocoaPods

`pod 'TTReflect', '~> 4.0.0'`

### 适配 Xcode8 & Swift3 (iOS 8+)
1. 切换到`swift3`分支, 手动拖拽`Reflect.swift`文件到你的项目中

2. CocoaPods (版本1.1.1或更高)

`pod 'TTReflect', '~> 3.0.0'`

### 适配 Swift2.3 (iOS 8+)
1. 切换到`swift2.3`分支, 手动拖拽`Reflect.swift`文件到你的项目中

2. Cocoapods

`pod 'TTReflect', '2.1.0'`

### 安装
#### iOS 7
##### 手动导入
将`Reflect.swift`拖到项目中即可使用

#### iOS 8+
##### 使用CocoaPods安装

```
platform :ios, '8.0'
use_frameworks!
pod 'TTReflect', '~> 3.0'
```

使用前需要导入框架
```
import TTReflect
```
=======


### 使用
#### 推荐模型样式

```
class Tag: NSObject {
    var count: Int = 0
    var name: String = ""
    var title: String = ""
    var isOpen: Bool = false
}
```

> 推荐所有的属性都使用默认值，能够避免在原始数据错误时，过多的可选判断或空对象崩溃

**1.模型需要继承于NSObject**

**2.Int等基本属性需要设置默认值**

**3.对象属性可以使用可选类型**

> 各类模型定义方式，详见 [测试模型](https://github.com/TifaTsubasa/TTReflect/tree/master/Example/Model)

#### 关键方法
```
// e.g. 模型为Tag类
// convert json to object
let tag = Reflect<Tag>.mapObject(json: json)
// convert data to object
let tag = Reflect<Tag>.mapObject(data: data)
// convert json to object array
let tags = Reflect<Tag>.mapObjects(json: json)
// convert data to object array
let tags = Reflect<Tag>.mapObjects(data: data)
```

#### 实例
**具体见代码示例**
##### 字典转模型

###### 指定需要转换的json或data，并指定转换的模型类型

```
let book = Reflect<Book>.mapObject(json: json)
let book = Reflect<Book>.mapObject(data: data)
```
![Alt text](http://images.upmer.com/TTReflect_mapObject.png)

##### 字典数组转模型数组
###### 指定需要转换的json或data，并指定转换的模型数组内的元素类型
```
let casts = Reflect<Cast>.mapObjects(json: json)
let casts = Reflect<Cast>.mapObjects(data: data)
```
![Alt text](http://images.upmer.com/TTReflect_mapObjects.png)



=======

### 补充方法
**补充方法皆遵守于协议，可代码提示**
#### 1.需要替换的属性名
希望将json的`title`属性对应到模型的`tt`属性

```
func setupMappingReplaceProperty() -> [String : String] {
    return ["tt": "title"]
}
```

#### 2.模型内嵌套子类模型
需要指定子类模型的key以及子类的类名

```
func setupMappingObjectClass() -> [String : AnyClass] {
  return ["images": Images.self]
}
```

#### 3.模型内嵌套子类模型数组
需要指定子类模型数组的key以及子类的类名

```
func setupMappingElementClass() -> [String : AnyClass] {
  return ["tags": Tag.self]
}
```

#### 4.需要忽略属性
指定需要忽略的属性名

```
func setupMappingIgnorePropertyNames() -> [String] {
  return ["tags"]
}
```

#### 完整模型演示
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

#### 完整转换效果
![Alt text](http://images.upmer.com/TTReflect_fullmap.png)



=======
### 帮助
1.如果在使用过程中遇到bug，或是有期待的功能，请留下Issues联系我，我将尽快答复

2.如果希望能够完善这个框架，敬请pull request

**E-mail: tifatsubasa@163.com**
