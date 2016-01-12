#TTReflect
####swift版 json转model 框架


````

###安装
####iOS 7
#####手动导入
将TTReflect.swift拖到项目中即可使用

####iOS 8+
#####使用CocoaPods安装

```
platform :ios, '8.0'
pod 'TTReflect', '~> 0.1.0'
```
````


###使用
####模型要求

```
class Tag: NSObject {
var count: Int = 0
var name: String?
var title: String?
}
```

**1.模型需要继承于NSObject**
**2.Int等基本属性不可以使用可选类型**

####关键方法
![Alt text](http://7xq01t.com1.z0.glb.clouddn.com/TTReflect_main_function-zh.png)

####实例
**具体见代码示例**
#####字典转模型

######指定需要转换的json或data，并指定转换的模型类型

```
let book = Reflect.model(bookData, type: Book.self)
```

![enter image description here](http://7xq01t.com1.z0.glb.clouddn.com/tsusolo.com/qiniumodel_basic.png)
#####字典数组转模型数组
######指定需要转换的json或data，并指定转换的模型数组内的元素类型

```
let casts = Reflect.modelArray(castsData, type: Cast.self)
```
=======
let book = Reflect.model(bookData, type: Book.self)
![enter image description here](http://7xq01t.com1.z0.glb.clouddn.com/tsusolo.com/qiniumodel_basic.png)
#####字典数组转模型数组
######指定需要转换的json或data，并指定转换的模型数组内的元素类型
let casts = Reflect.modelArray(castsData, type: Cast.self)


![enter image description here](http://7xq01t.com1.z0.glb.clouddn.com/tsusolo.com/qiniumodel_array_basic.png)


````

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
=======
func setupReplacePropertyName() -> [String : String] {
return ["title": "tt"]
}
####2.模型内嵌套子类模型
需要指定子类模型的key以及子类的类名

func setupReplaceObjectClass() -> [String : String] {
return ["images": "Images"]
}
####3.模型内嵌套子类模型数组
需要指定子类模型数组的key以及子类的类名

func setupReplaceElementClass() -> [String : String] {
return ["tags": "Tag"]
}
####完整模型演示

>>>>>>> 4a9e9fbfd1043cc31ee417333c286ccc687e8808
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

####完整转换效果
![enter image description here](http://7xq01t.com1.z0.glb.clouddn.com/tsusolo.com/qiniumodel_full.png)


````

###帮助
1.如果在使用过程中遇到bug，或是有期待的功能，请留下Issues联系我，我将尽快答复

2.如果希望能够完善这个框架，敬请pull request

=======
###帮助
1.如果在使用过程中遇到bug，或是有期待的功能，请留下Issues联系我，我将尽快答复
2.如果希望能够完善这个框架，敬请pull request
>>>>>>> 4a9e9fbfd1043cc31ee417333c286ccc687e8808
**E-mail: tifatsubasa@163.com**