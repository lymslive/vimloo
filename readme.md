# Basic of Object Orient Programming in Viml Script
`vimloo` `git/readme`

## Introduction

* class is a dict variable defined in a script which under the autoload
  subdirecotry, class name is the relative path to autoload.
* object instance is a copy of class, may with modified data keys.
* derived class is also a copy of base class, may add data or/and function
  keys.
* module is a isolate class by itself with no child, parent nor even instance.

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

* requirement: vim7.4 or above
* for common user, only the code in `autoload/` is needed
* for VimL Plugin writer, the command in `plugin` may also be helpful

## Documentation

Online help `doc/vimloo.txt` is available.

A _chinese version_ readme is also availabe
([一份中文的说明文档也是可利用的](readme-zh.md)).
