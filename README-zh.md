#TTReflect
####swift版 json转model 框架

### 更新记录
#### 1.0.0
###### 1.更新方法名称
###### 2.更改在原数据错误时，默认返回空对象而不是nil，避免在未对可选对象解析时的空对象崩溃

###安装
####iOS 7
#####手动导入
将TTReflect.swift拖到项目中即可使用

####iOS 8+
#####使用CocoaPods安装

```
platform :ios, '8.0'
use_frameworks!
pod 'TTReflect', '~> 1.0.0'
```

需要导入框架
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

####关键方法
![Alt text](http://7xq01t.com1.z0.glb.clouddn.com/reflect_method_name.png)

####实例
**具体见代码示例**
#####字典转模型

######指定需要转换的json或data，并指定转换的模型类型

```
let book = Reflect.model(data: bookData, type: Book.self)
let book = Reflect.model(json: bookJson, type: Book.self)
```

![enter image description here](http://7xq01t.com1.z0.glb.clouddn.com/tsusolo.com/qiniumodel_basic.png)
#####字典数组转模型数组
######指定需要转换的json或data，并指定转换的模型数组内的元素类型
```
let casts = Reflect.modelArray(data: castsData, type: Cast.self)
let casts = Reflect.modelArray(json: castsJson, type: Cast.self)
```

![enter image description here](http://7xq01t.com1.z0.glb.clouddn.com/tsusolo.com/qiniumodel_array_basic.png)


=======

###补充方法
**补充方法皆遵守于协议，可代码提示**
####1.需要替换的属性名
希望将json的`title`属性对应到模型的`tt`属性

```
func setupReplacePropertyName() -> [String : String] {
    return ["title": "tt"]
}
```

####2.模型内嵌套子类模型
需要指定子类模型的key以及子类的类名

```
func setupReplaceObjectClass() -> [String : String] {
    return ["images": "Images"]
}
```

####3.模型内嵌套子类模型数组
需要指定子类模型数组的key以及子类的类名

```
func setupReplaceElementClass() -> [String : String] {
    return ["tags": "Tag"]
}
```

####完整模型演示
```
class Book: NSObject {
    var tt: String = ""
    var pubdate: String = ""
    var image: String = ""
    var binding: String = ""
    var pages: String = ""
    var alt: String = ""
    var id: String = ""
    var publisher: String = ""
    var summary: String = ""
    var price: String = ""
    var images: Images()
    var tags = [Tag]()

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

####完整转换效果
![enter image description here](http://7xq01t.com1.z0.glb.clouddn.com/tsusolo.com/qiniumodel_full.png)


=======
###帮助
1.如果在使用过程中遇到bug，或是有期待的功能，请留下Issues联系我，我将尽快答复

2.如果希望能够完善这个框架，敬请pull request

**E-mail: tifatsubasa@163.com**
