# VimL 面向对象编程简易框架
`vimloo` `git/readme`

## 简介

用 VimL 的字典类型 dict 表示对象，据此提出一种用面向对象思想编写 VimL 插件脚本
的规范框架，以期利于 VimL 代码的利用与管理维护。

## 主要功能

* `class` 基类设计，提供诸多公用方法与函数。
* `tempclass` 模板类设计，作为自定义类的参考范例。
* `class#builder` 提供一些命令从 `tempclass` 中抽取代码片断，快速生成自定义类的代
  码。
* 其他辅助有利于写 VimL 的脚本或命令工具。

## 快速使用

* 用 `class#new()` 函数创建对象实例，用 `class#old()` 创建派生子类。
* 类定义文件应该保存在 `autoload` 或其子目录下。

## builder 生成命令

* `:ClassNew classname` 当前目录需在 `autoload` 或其子目录，生成
  `classname.vim` 文件作为 `classname` 类定义文件。
* `:ClassAdd` 与 `:ClassNew` 类似，但在当前编辑的文件中添加类定义代码，类名根
  据文件名决定，当前文件须在 `autoload` 或其子目录下。
* `:ClassTemp` 与 `:ClassAdd` 类似，但不要求当前文件在 `autoload` 目录下。只是
  将 `tempclass` 的代码载入临时查看。

这三个命令支持许多选项参数，用于指定包含或不包含模板类定义中的某些方法组件。
用 `:ClassTemp -a` 将 `tempclass.vim` 全部内容载入。该源文件中每段前的注释中标
记了选项参数，小写字母表示默认提取，大写字母表示默认不提取。这三个命令末尾加附
加选项覆盖源文件中指定的选项（各选项字母组合一起当作一个参数传入）

* `:ClassPart -xyz` 必须带上选项参数，只将指定参数的源文件段提取，忽略源文件中
  自己标记的默认选项。主要用于已用 `:ClassNew` 或 `:ClassAdd` 添加类代码后，需
  要补充少量遗漏的组件。
