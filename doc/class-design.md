# class 类设计思路详解

## 类文件

定义类的文件应置于 `autoload` 或其子目录下。例如
`foo` 类的定义应保存在 `autoload/foo.vim` 文件中，
`foo#bar` 类定义保存在 `autoload/foo/bar.vim` 文件中。
这样，只要将 `autoload` 所在父目录添加至 Vim 的 `&rtp` 中，
就能在任意脚本中使用所定义的类。

类定义文件中可能存在三种不同作用类型的函数，本文档标以不同术语：

* 全局可用的脚本函数，带 `#` 号的全路径函数名，如 `path#function`
* 保存在类字典中的方法，如 `s:class.method`
* 限本脚本可用的私有函数，一般用于算法辅助，如 's:Function'

## 必需构成

类是一个字典，所以在类定义文件必须定义一个字典变量。
为表明这是用于定义类的字典，取名为 `s:class`。
这是脚本作用域的变量，每个脚本都可这个变量名，代表各自不同的类。

```
let s:class = {}
let s:class._name_ = 'class'
let s:class._version_ = 1

function! class#class() abort
  return s:class
endfunction
```

为这个类（字典）添加了两个保留的成员，`_name_` 与 `_version_`。
子类（例如 `tempclass`）继承自 `class` 的话，第一行应写作：
```
let s:class = class#old()
```
此时则会给类字典再加一个 `_surper_` 属性，保存父类的类名。

自定义子类时，可在其后添加其他所需的成员。建议每行用 `let` 命令
定义一个成员，并设置合适的变量类型及初始值。

然后需要一个 `#class()` 函数返回这个类字典。这样在 VimL 其他地方
也就能引用这个类定义了。

## 创建实例的 new 函数

按惯例命名，用 `#new()` 函数创建该类的实例对象。
实例对象其实就是类对象的复制。该方法需要返回新建的对象变量。

```
function! tempclass#new(...) abort
  let l:obj = copy(s:class)
  call l:obj._new_(a:000)
  return l:obj
endfunction
```

`class` 基类中定义了一个 `_new_()` 成员方法，
用于统一封装一些公共操作，它将传给 `#new()` 函数的参数打包，
转发给构造函数 `#ctor()`。

基类的 `new` 函数，即 `class#new()` 函数，有略微不同的定义，
它可以接受第一个参数为类名，其后再跟着传给该类的构造函数的参数。
以下两个语句是等效的：
```
let obj = tempclass#new(arg-list)
let obj = class#new('tempclass', arg-list)
```

因此子类其实可以不必定义 `#new()` 函数。但若定义了自己的 `#new()`
函数，以后创建对象写法上会更方便些。同时也可根据需求自行调整
`#new()` 函数的实现，比如不再通过 `_new_()` 方法中转调用自已的
`#ctor()` 构造函数，可直接明写调用自己的构造函数。

这后面介绍的函数，严格来说，都不是必须的。但当需要时，用统一的规范
实现代码，会优雅一些吧。

## 构造函数 ctor

构造函数由 new 函数调用或间接调用。其参数定义有讲究，如：

```
function! tempclass#ctor(this, argv) abort
  let l:Suctor = s:class._suctor_()
  call l:Suctor(a:this, [])
endfunction
```

调用构造函数时，对象已经创建（由 new 函数创建），故用 `a:this`
代表这个新建的对象。`this` 与 `class` 都不是 VimL 的关键词，
完全可用其他名字代替，但能用这两个名字岂不更好。

`#ctor` 的第二个参数 `argv` 是一个列表，包含了用户传给 `#new(...)` 
的所有参数，即是其 `a:000` 列表。VimL 不能重载函数，但可通过参数个数
与类型（`:h type`）进行逻辑判断，作不同的初始化。

子类的构造函数可以调用父类的构造函数，如何调用
（何时调用，在自己实际工作之前或之后，以及传哪些参数）
应该由子类的实现者决定。
甚至如果能确知父类构造函数其实无事可干，也可以不调用。

`class` 基类提供了 `_suctor_()` 方法用于获取父类的 `#ctor()` 函数引用，
也用 `_ctor_()` 方法用于获取自己的 `#ctor()` 构造函数引用。

在构造函数中一般根据参数给相应成员赋值，或者在缺省参数时给默认值。
由于 VimL 类的动态性，也可以直接在这里添加新成员属性。
然而良好的实践，仍是在前面创建 `s:class` 类对象时立即列出所设计
的所有成员属性。不过要注意的是，如果成员值本身也是列表或字典，
由于在 `#new` 函数中是浅拷贝，必须在构造函数中重新初始化。
除非该属性本就设计为所有对象共用的列表或字典，即静态属性。

## 拷贝构造函数 copy

```
function! tempclass#copy(that, ...) abort
  let l:obj = copy(s:class)
  call l:obj._copy_(a:that)
  return l:obj
endfunction 
```

其实这个函数的用意不是拷贝一个同类的对象，因为那直接用内置函数
`copy()` 就可以了。这里提供这个函数可用于两个目的：

* 通过一个普通字典变量构建对象，按相同的键名赋值，避免用 `#new()` 函数记忆位置参数；
* 将一个父类对象变成子类对象，除了复制父类已有的部分属性外，
  还可提供额外参数用于初始化子类新增的属性。

所以在 `class` 基类中提供了一个 `_copy_()` 方法，它只根据自身已定义
的键名，从传入的参数字典中择取相应的键值复制。忽略保存函数引用的键，
即只复制纯数据，不复制方法。另外，对于是列表或字典类型的属性成员，
采用复制的方法（内置 `copy()` 函数），而不是直接赋值。

由于该函数也设计为构建一个新对象，故需返回一个对象。

## 继承函数 old

```
function! tempclass#old() abort
  let l:class = copy(s:class)
  call l:class._old_()
  return l:class
endfunction
```

准确地说，这是“被继承”函数。它规定了别人如何从自己这里派生出一个子类。
子类也是一个对象，或字典。所以这个函数得返回一个能表示子类的对象。

因为这个函数的实现与 `#new()` 函数创建实例对象极其相似，就是复制自己
然后返回。所以针锋相对地，命名为 `old`。请记得 Linux 一句谚语：
less is more, old is newer.

`class` 基类提供的 `_old_()` 方法，将 `_super_` 属性设为自己，
再清空 `_name_` 属性值，这要求创建子类返回后，让子类自己明确
写上它自己的名字。

`class` 基类的 `#old()` 函数又略有特殊，它与 `#new()` 函数一样，
可接收第一个参数表示类名，表示要继承哪个类。如以下两句等效：
```
let sub = somebase#old()
let sub = class#old('somebase')
```

所以一般情况下，也不需要提供自定义类的 `#old()` 函数。
但若有意设计为基类使用，提供 `#old()` 函数将使意图更明显，
同时也可以对继承作更多的控制。比如在返回子类之前，删去某些属性，
那这些属性就相当于私有的，无法被子类继承了。

## 析构函数 dector

这个函数应该极少用到。但是 `class` 基类也提供了一个 `#delete()` 
函数，它将沿着继承路径自下而上，调用每个类的 `#dector()` 函数。
所以如果实有需要清理工作的情况下，可为自定义类添加一个 `#dector()`
函数，不带参数，并调用 `class#delete(obj)` 析构之。

## 单例 instance

单例可用如下代码实现：

```
let s:instance = {}
function! tempclass#instance() abort
  if empty(s:instance)
    let s:instance = class#new('tempclass')
  endif
  return s:instance
endfunction
```

这只是创建了一个全局共享的对象实例。但并不能阻止创建其他的实例。
可以删去或不提供 `#new()` 构造函数来表明这个设计意图，但仍可用
基类的 `class#new('classname', ...)` 来创建实例。

## 成员方法

成员方法的定义按如下示例语法添加：

```
function! s:class.string() dict abort
  return self._name_
endfunction

function! s:class.number() dict abort
  return self._version_
endfunction
```

请注意函数命令之后的 `dict` 关键字，它表示该函数可从一个字典调用，
在函数体内的 `self` 关键字就代表这个字典，也就是对象自身。

`class` 基类提供的 `string()` 与 `number()` 方法，也是有意图的。
可将其视为类型转换函数，考虑如何将一个对象用一个字符串或数字来表达。

保留属性 `_version_` 也不仅为 `number()` 方法有值可返回，
说不定将来有需要可用之作版本控制之用呢。

此外，`class` 基类提供一个卖萌的 `hello()` 方法，会调用 `string()`
`number()` 这俩方法，尽可试用（`hello` 方法可带一个参数或省略）

## 加载控制

```
if exists('s:load') && !exists('g:DEBUG')
  finish
endif

类实现代码

let s:load = 1
function! tempclass#load(...) abort
  if a:0 > 0 && !empty(a:1) && exists('s:load')
    unlet s:load
    return 0
  endif
  return s:load
endfunction
```

设置一个 `s:load` 变量，阻止重复加载脚本。但是如果在脚本开发调试
或其他原因修改后有意重新加载时，那就需要有机制回避这个保护机制了：
* 设置 `g:DEBUG` 变量；
* 调用 `#load(1)` 删除 `s:load` 变量。

如此之后，再用 `:source` 命令就能重新加载脚本了。

## 单元测试

```
function! tempclass#test(...) abort
  return 0
endfunction
```

最后，建议为每个类或功能复杂的普通脚本，写个 `#test()` 函数吧。

## 附注：

本文截取的代码片断就是 [tempclass.vim](../autoload/tempclass.vim) 的内容。
用 `:ClassNew` 或 `:ClassAdd` 生成自定义类时，会自动将 `tempclass#`
替换为正确的类名路径。命令所支持的选项可用 `:ClassTemp -a` 载入
源文件全文件后直接查看。

一些较有实际用途的类定义可参考 [class/](../autoload/class) 子目录下的实现代码。
