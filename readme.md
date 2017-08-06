# Basic of Object Orient Programming in Viml Script
`vimloo` `git/readme`

## Introduction

* `class` is a dict variable defined in a script which under the autoload
  subdirecotry, class name is the relative path to autoload. Each class file
  only has a class, with reserved `_name_` key to store the '#-path name'.
* `object` instance is a sub-copy of class, may with modified data keys.
* `derive` class is also a sub-copy of base class, may add data or/and function
  keys.

## Functionality

* base class design, providing many fundamental methods and functions.
* template files to make it easy to create custome class and module.
* some other smart commands used in script to help writting viml code in a more
  pretty way.

## Install

Just clone down this rep to a runtime path of vim(`&rtp`), or use some plugin
manage tool to Install. For example:

```sh
$ mkdir -p ~/.vim/pack/lymslive/opt
$ cd ~/.vim/pack/lymslive/opt
$ git clone https://github.com/lymslive/vimloo
```

* requirement: vim7.4 or above, recommanded vim8.0
* for common user, only the code in `autoload/` is needed
* for VimL Plugin writer, the command in `plugin` may also be helpful

Any vimer can feel free to install this plugin, because by default, there is
no effect on your own vim evironment or habit, expcept some disk space, and an
item longer of vim's `runtimepath`. The script code in `autoload/` is sourced
only when needed, and so little effect on the speed of vim startup.

## Command

For viml script writer, add one of the following config to `.vimrc`:
```vim
let g:vimloo_plugin_enable = 1
let g:vimloo_ftplugin_enable = 1
```
or
```vim
call vimloo#plugin#load()
```

Then some useful command is definded for writting vim script.

* `:ClassNew {name}` when currnet director is under some `autoload`
  sub-director, or given `name` as full path, this command will create a new
  file with `name.vim`, and auto generate a class definition by that name.
* `:ClassAdd` when editing an exisited vim file, this will append a class
  definition by the current file name.
* `:ClassPart {option}` the default behavior of `ClassNew` or `ClassAdd` only
  generate minimun required component, this command will add more later. Refer
  to the template class file [autoload/tempclass.vim](autoload/tempclass.vim).
* `:ClassTest [argumemt list]` if the class file contain a `#test()` function,
  this will call that function, and extra command argument is also passed.
* `:ClassRename` if the class file is moved to another place, the funtion names
  `path#to#class#func()` will be wrong, this commnad is used to repair such
  problem.

## Function

Some of most import functions to define and use class are:

* `class#new()` create an object instance, anywhere when needed.
* `class#old()` create a derived class, mainly used in class file.
* `class#isobject()` determined whether a virable is an instance of a class.
* `class#use()` import a class package to where used frequently, avoid
  `long#path#to#class#name()`.

Function argument is not included above, detail refer to online help doc. It's
common to define their own `path#to#class#new()` functions in each individul
class file. The later usually has one less argument than the base `class#new()` 
functios, since the sepcific `s:class` is passed to `class#new()`, for example.

## Plugin Practice

There are some vim plugins based on `vimloo`, and so `vimloo` must be
installed with any of them:

* [vnote](https://github.com/lymslive/vnote)
* [StartVim](https://github.com/lymslive/StartVim)
* [tygame](https://github.com/lymslive/tygame)

## Documentation

Online help `doc/vimloo.txt` is available.

A _chinese version_ readme is also availabe
([中文补充文档](readme-zh.md)).

## Change Log

* 2017-8: class.vim version change to 2. The base class mechanism has improved
  much compare to version 1. The object dictionary struct is not necessary the
  same as class dictionary. A class is mainly direct on how to create an
  object.
