# VimL 基础对象模型教程

VimL 语言其实并没有内置的对象概念。其变量类型主要有两种简单标量（数字与字符串）
与两种集合类型（列表与字典）。但在字典的键中不仅可存普通变量，还能存函数（实际
是函数引用 Funcref），因而字典就可以当作对象来使用了。

## 字典当作对象使用 (dict as object)

字典的常规定义与使用如：
```
let dic = {'x': 3, 'y': 4}
echo dic['x']
echo dic['y']
```

但是，也可写成这样：
```
let obj = {}
let obj.x = 3
let obj.y = 4
echo obj.x + obj.y
```

这就有点像对象的点号引用语法了。当然了，要用点号引用字典的键，那个键不能用奇怪
字符串，须用正常的能用于变量标志符的字符串。

## 用字典的键保存函数

用如下语法定义一个函数并保存在字典中：
```
function! obj.distance() dict
  return sqrt(self.x*self.x + self.y*self.y)
endfunction
```

与常规函数相比，其函数名不是简单的变量名，而是 `obj.distance`，表示它是存于字
典 `dict` 中的键名 `distance` 中。可以分别用如下命令查看一下这像什么情况：
```
echo obj.distance
echo obj['distance']
echo obj
```

函数定义头行末尾的关键字 `dict` 表示该函数通过字典变量调用，此时函数体中的
`self` 就代表该字典本身。调用方法如下：
```
echo obj.distance()
echo obj.distance() * 2
```

请注意，带括号的 `obj.distance()` 表示函数调用，它返回函数计算值 `5.0`。而不带
括号的 `obj.distance` 等效于 `obj['distance']`，获取这个键名中所存的东西，它是
个函数引用。

## 类与实例：实例是类字典的拷贝

可以继续为上面的字典变量 `obj` 添加更多的属性（键存值）与方法（键存函数）。然
而它始终还只是一个“对象”，如何抽象出更“类”的东西呢。可以这样写：
```
let class = {}
let class.x = 0
let class.y = 0
function! class.distance() dict
  return sqrt(self.x*self.x + self.y*self.y)
endfunction

let obj1 = copy(class)
let obj1.x = 3
let obj1.y = 4
echo obj1.distance()

let obj2 = copy(class)
let obj2.x = 30
let obj2.y = 40
echo obj2.distance()

echo obj1.distance == obj2.distance
echo obj1.distance() == obj2.distance()
```

上面第一段代码，定义了一个“类” 也即一个名为 `class` 的字典。为该类定义了两个属
性名为 `x` `y` 及一个方法 `distance`。然后以这个类为模板，创建了两个“实例”对象
。最后两行演示相等性，这两个对象的 `distance` 方法是相同的，但它们各自调用
`distance()` 方法产生的结果是不相等的。

从 VimL 角度看，`class` `obj1` `obj2` 都只是三个不同的字典变量。键名 `x` `y`
存的是值，相互独立，键名 `distance` 保存的函数引用，却是引用同一个函数。

## 类与对象的动态性

既然类与对象都是字典，那么可以继续为其添加属性（键值）而互不影响。如：
```
let class.z = 0
let obj1.a = obj1.distance()
let obj2.b = obj2.distance()

function! class.product() dict
  return (self.x*self.x + self.y*self.y)
endfunction

let obj3 = copy(class)
echo obj3.product()
let obj3.x = 3
let obj3.y = 4
let obj3.z = obj3.product()
echo obj3.z
```

为类 `class` 新加一个属性 `z`，但已创建的实例 `obj1` `obj2` 不会有这个属性。
`obj1` 新加一个 `a` 属性来保存 `disctance()` 的计算值，`obj2` 也不会有 `a` 属
性。`obj2` 新加的 `b` 属性亦然。

特别地，如果为类 `class` 新定义一个 `product` 方法，则原来的 `obj1` `obj2` 不
可调用该方法。但若此后再创建一个 `obj3`，它就可用 `product` 方法了，因为它从此
刻的 `class` 字典中拷贝过来了。

## 继承：子类也是父类的拷贝

如下代码，可以在原来的类基础上创建新类：
```
let subclass = copy(class)

" 添加新的属性，或覆盖原来的键值定义

let subobj = copy(subclass)
```

由于 VimL 是弱类型语言，那也就容易实现多态了。比如把许多不同类的实例对象，保存
在一个列表内，对它们调用同一个方法，那显然会根据它们各自保存的函数引用调用相应
的实现方法了。
