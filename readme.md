# VimL 脚本模块化的包管理机制及面向对象组织框架
`vimloo` `git/readme`

## 内容简介

这是着重于 VimL 脚本的插件，而非 Vim 的插件。
主要目的与思想是将 VimL 脚本像其他“常规”脚本一样模块化，
然后需要一种包管理机制，将不同模块内的私有函数（与对象、类定义）
通过明确的导入导出方法，在其他脚本模块内共享。

核心是 `autoload/` 目录下的几个脚本：

* `package.vim` 包管理与模块导入机制，可独立使用。
* `object.vim` 通用对象机制，最好与 `package.vim` 的导出功能联用。
* `class.vim` 稍复杂点的类文件规范，不依赖 `package.vim`（其实是先写的）
   但由于将内部处理字典的部分单独抽出（仍在本仓库），却不宜单独使用。

这几个核心脚本，或多或少对 VimL 写法有一定的规范要求，但力求自然与
最小惊讶原则。

至于 `autoload/` 目录下的其他子目录，则是一些代码库。有自己写的，也有
从其他优秀插件中提取的通用脚本库。

* `jp#` 源自日本社区的 [vimtal](https://github.com/vim-jp/vital.vim)
  但对部分模块作了简单的相互引用调整，改用 `package.vim` 的方式。
* `ly#` 个人帐号前两字母缩写代表的命名空间，按 `package.vim` 方式
  写的面向过程化的通用模块，将保存在该目录下。
* `class#` 按 `class.vim` 规范写的类文件，放在该目录下。

本仓库希望有助于开发 VimL 项目，如比较复杂的插件，在需要将不同功能
分解至不同脚本（模块）时，能更方便有序地组织脚本代码。同时也能更方便
地复用别人已经写的可通用模块。

## 安装使用

无需特殊安装，将本仓库下载至任一能加入 vim `&rtp` 路径的目录即可。
也可以用任意 vim 插件管理工具安装。

本插件几乎不会影响 vim 的个性环境，不会修改任何设置与快捷键等。
只有 `autoload/` 目录下的自动加载脚本，默默等待发挥作用。 

## 模块导入导出实践

一个 VimL 模块就是一个 `*.vim` 文件，最好是放在某个 `&rtp` 目录的
`autoload/` 子目录。定位一个模块，有以下三种路径表示法：

1. 标准路径，形如 `path#to#mod` 的以 `#` 分隔的路径，遵循 vim 的自动
   加载机制。文件只能放在某个 `autoload/` 之下，不包括 `.vim` 后缀。
2. 绝对路径，形如 `/root/path/to/mod.vim` 或 `./path/to/mod.vim` 的路径，
   可以表示 `autoload/` 之外的文件，且要指定 `.vim` 后缀名。
   路径分隔符 `/` 取决于实际操作系统。
3. 相对路径，形如 `path.to.mod` 或 `.mod_in_current` 的路径，
   以点分隔路径，但在无子目录时，为防与第 1 种标准路径区分，得在最前面
   再加个点。同时显然应省略 `.vim` 后缀名。

在第 3 种点号相对路径与第 2 种以 `./` 或 `../` 开头的系统相对路径，
都还涉及一个相对基准的问题，这取决于具体使用函数或命令的设计环境。

以 `#` 分隔的标准路径，也称为模块的命名空间。为文法区别，将每个模块
下的 `s:` 特殊字典称为脚本作用域，而不称符号空间。

### package.vim 导入方法

* `package#import(module, ...)` 模块名使用标准路径定位，返回一个字典。
  如果指定额外参数，字典中只包含指定的键。也允许使用完全的绝对路径。
* `package#imports(module, key1, ...)` 至少要指定一个键名参数，
  在类似导入基础上，只返回指定键的值，不涉及外层字典。
* `:USE[!] moudle [key1, key2]` 命令式的导入方法，模块名与额外参数键
  不用加引号。模块名可用标准路径、绝对路径与相对路径，相对路径的基准
  是当前脚本，即使用该命令的脚本。命令无返回值，故将导入的字典以模块
  名的末尾部分命名，注入当前脚本作用域 `s:`，如果加 `!` 变种，则还省略
  字典变量这个中间层，直接将每个键名的符号导入。
* `package#new(name, [base])` 返回一个局部的包管理对象，基准路径是
   `base` 参数，如省略则同 `name` 参数。该对象的 `.import()` 方法
   类似全局的 `package#import()` ，除了支持标准路径与绝对路径外，
   还支持相对路径，相对基准即是构建对象时的 `base` 参数。

### 模块导出规范

首先，模块导入可以兼容毫无规范的模块。只要源模块脚本内写了一堆以脚本
作用域的 `s:` 函数，用 `package#import()` 或 `:USE` 就能导出这些私有
函数。但不能导入 `s:` 作用域的私有变量（或对象），也不能（其实不需）
导出全局函数（包括含 `#` 的全局函数）。

但是，源模块可以提供以下函数，定制自己觉得需要导出的符号表：

1. `#export()` 或 `s:_export_()`
2. `#class()` 或 `s:_class_()`
3. `#package()` 或 `s:_package_()`

然后在导入端，会按以上优先级顺序，调用存在的第一个函数。将其返回值
当作（初步待导入）的符号表，一般应该是字典。但是，又有以下几种纠正：

* 如果导出表的字典含有 `EXPORT` 这个键，则改用这个键的值当作实际
  待导出的表。
* 如果导出表不是字典变量，而是一个字符串列表，则将每个字符串视为
  `s:` 私有函数名，以这些键名重建导出字典表。
* 如果导出表字典中，含有 `<SID>` 这个特殊键（一般也就还有其他键），
  则额外将 `s:` 私有函数也添加于导出表中。`<SID>` 键的值，视为正则
  表达式，如为空则默认过滤掉以下划线开始的函数名。

简言之，`package.vim` 机制可以方便导入其他模块中定义的 `s:` 函数。
如果这不满足需求，可定制导出函数；其他看视复杂的规则，只为手写定制
导出函数更简便一点而已。

以下划线开头的 `s:_xxx()` 函数，视为“真私有”函数，默认不导出。

### 模块导入规范

在脚本中使用（导入）其他模块，这更自由，更少限制。

* 使用合适的变量名接收 `package#import()` 的返回值。可用在函数内
  赋给 `l:` 变量，但如常用，建议在函数赋给 `s:` 变量，且写在脚本
  开头处，意图表明本模块需要导入其他模块。
* 在只要用到其他模块的一个（或少量几个）函数时，用 `package#imports()`
  更方便，但在函数内用 `l:` 变量接收时，注意要大写，函数引用名要大写。
* 用 `USE` 命令往本地作用域注入变量，需要开启一个后门，在当前脚本定义
  一个 `#package()` 函数，并返回 `s:` 。命令相比函数更方便相对导入。
  当然符号注入要谨防名字污染与冲突。
* `package#new()` 构建本地包管理对象，可用在插件开发中，以插件名当作
  对象的基准目录，方便互相导入调用同插件下的脚本。
  也可以用于简化长命名空间下的模块导入写法。

### 通用对象 objcet 规范

`object` 对象（字典）采用极懒加载工作方法，最初只有一个成员，四个方法：

* `object['@ISA']` 对象的父类对象列表，每个元素是字典，如果是字符串，
  则应该能将该字符串作为模块名用 `package#import()` 导出字典。
* `object.has(key1, ...)` 判断对象是否含有某个键（或多个键）。
* `object.get(key, [default])` 获取一个键值，可指定默认值。
* `object.set(key, val)` 设定一个键值。
* `object.call(key, ...)` 调用一个方法，键值应该是一个函数引用。

在调用上述四个基本方法时，如果当前字典中没有该键，则从 `@ISA` 列表的
字典中寻找（按实现是深度优先），并将找到的第一键值复制到当前字典中。
此后就可直接引用该键，而不必间接调用了。

使用 `object#new(...)` 函数创建一个新对象，并将参数视为新对象的父类，
存入新对象的 `@ISA` 列表中。可以马上调用新对象的 `has()` 方法，将关心
的键名都传入参数，权当作成员检查或成员声明。

### 单类模块文件 class 规范

按 `class.vim` 的规范，一个模块文件只能定义一个类，类名就是其标准路径。
并有以下规范要求，定义如下自动加载全局函数：

* `#class()` 返回类定义字典（必须）
* `#new()` 返回一个类实例化对象
* `#ctor()` 对象的构造函数，由 `#new()` 通过内部方法间接调用。

更多规范或建议可参考 `autoload/tempclass.vim` 模板示例类文件。

`class` 类的实现相对繁重，在类（与对象）创建时就从祖先处复制了所有键。
这在长继承链中，需要大量创建叶结点时，空间利率可能很不好。
但优点是清晰，与模块文件一一对应，也容易查找类定义。

`object` 对象相对轻量，允许在一个模块中定义多个（相关的）类。`object`
继承时可兼容 `class` 规范的类。

## 辅助工具

曾为编写与高度规范的类文件写过一些辅助工具，后来觉得这不属于 VimL 模块
机制的范畴，就移到他处了。

* 类文件模板生成，另见 `lymslive/autoplug` 仓库
  [autoload/template](https://github.com/lymslive/autoplug/tree/master/autoload/template) 目录。
* VimL 脚本调试相关，另见 `lymslive/autoplug` 仓库 
  [autoload/debug](https://github.com/lymslive/autoplug/tree/master/autoload/debug) 目录。

## 更多参考文档

主要文件列表及简单说明见 [content.md](content.md)。
VimL 脚本源文件虽都用英文注释，但并未能写英文的 help 文档，
然而提供了几篇中文的 .md 文档可供参考。

* [doc.md/class-dict](doc.md/class-dict.md) VimL 基础对象模型入门教程
* [doc.md/class-design](doc.md/class-design.md) class 基类设计思路详解
* [doc.md/vimlmod](doc.md/vimlmod.md) package 导入机制详解
* [doc.md/vimllib-jp](doc.md/vimllib-jp.md) 使用 vital 库
