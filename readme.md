# Basic of Object Orient Programming in Viml Script
`vimloo` `git/readme`

## Introduction

* `class` is a dict variable defined in a script which under the autoload
  subdirecotry, class name is the relative path to autoload.
* `object` instance is a copy of class, may with modified data keys.
* `derive` class is also a copy of base class, may add data or/and function
  keys.
* `module` is isolate class by itself with no child, parent nor even instance.
* `interface` is open class that operate on an existed data structure, say
  list and dictionay the viml provides.

## Functionality

* base class design, providing many fundamental methods and functions.
* module management, wich can import both standard classfied module and non-standard
  modules.
* template files to make it easy to create custome class and module.
* some other smart commands used in script to help writting viml code in a more
  pretty way.

## Install

Just clone down this rep to a runtime path of vim(`&rtp`), or use some plugin
manage tool to Install.

* requirement: vim7.4 or above, recommanded vim8.0
* for common user, only the code in `autoload/` is needed
* for VimL Plugin writer, the command in `plugin` may also be helpful

Any vimer can feel free to install this plugin, because by default, there is
no effect on your own vim evironment or habit, expcept some disk space, and an
item longer of vim's `runtimepath`. The script code in `autoload/` is sourced
only when needed, and so little effect on the speed of vim startup.

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

## Documentation

Online help `doc/vimloo.txt` is available.

A _chinese version_ readme is also availabe
([中文补充文档](readme-zh.md)).
