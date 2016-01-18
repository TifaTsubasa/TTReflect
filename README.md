#TTReflect
####swift: json convert to model
**[中文介绍](https://github.com/TifaTsubasa/TTReflect/blob/master/README-zh.md)**

###Installation
####Manually
#####
drop `TTReflect.swift` to your project

####iOS 8+
#####CocoaPods

```
platform :ios, '8.0'
use_frameworks!
pod 'TTReflect', '~> 0.2.0'
```

**import lib**
```
import TTReflect
```


###Usage
####Model requirements

```
class Tag: NSObject {
    var count: Int = 0
    var name: String?
    var title: String?
}
```

**1.Your model should be subclass of `NSObject`**

**2.Can not use optionals for basic types, and you could use optional NSNumber? for `Int、long...`**

####Main function

![Alt text](http://7xq01t.com1.z0.glb.clouddn.com/tsusolo.com%2FqiniuTTReflect_main_function.png)

####Example

#####Dictionary -> Model

######Specifies json/data and model type

```
let book = Reflect.model(bookData, type: Book.self)
```

![enter image description here](http://7xq01t.com1.z0.glb.clouddn.com/tsusolo.com/qiniumodel_basic.png)

#####Array<Dictionary> -> Array<Model>
######Specifies json/data and array element type
```
let casts = Reflect.modelArray(castsData, type: Cast.self)
```

![enter image description here](http://7xq01t.com1.z0.glb.clouddn.com/tsusolo.com/qiniumodel_array_basic.png)

=======

###Protocol function

####1.Replace attribute

json["title"] reflect model.tt

```
func setupReplacePropertyName() -> [String : String] {
    return ["title": "tt"]
}
```

####2.Model of embedding model
Specifies subclass type and key in json

```
func setupReplaceObjectClass() -> [String : String] {
    return ["images": "Images"]
}
```

####3.Model array embedded in model
Specifies model array element type and key in json

```
func setupReplaceElementClass() -> [String : String] {
    return ["tags": "Tag"]
}
```

####Full model example
```
class Book: NSObject {
    var tt: String?
    var pubdate: String?
    var image: String?
    var binding: String?
    var pages: String?
    var alt: String?
    var id: String?
    var publisher: String?
    var summary: String?
    var price: String?
    var images: Images?
    var tags: Array<Tag>?

    func setupReplacePropertyName() -> [String : String] {
        return ["title": "tt"]
    }

    func setupReplaceObjectClass() -> [String : String] {
        return ["images": "Images"]
    }

    func setupReplaceElementClass() -> [String : String] {
        return ["tags": "Tag"]
    }
}
```

####Full reflect
![enter image description here](http://7xq01t.com1.z0.glb.clouddn.com/tsusolo.com/qiniumodel_full.png)


=======
###Help
1.Please commit issues when you encounter bug or expect new function, thanks!

2.Please pull request when you have good idea ^ ^

**E-mail: tifatsubasa@163.com**
