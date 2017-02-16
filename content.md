# vimloo 主要文件内容

* [plugin/vimloo.vim](plugin/vimloo.vim)
  全局命令定义
* [autoload/class.vim](autoload/class.vim)
  class 基类定义
* [autoload/tempclass.vim](autoload/tempclass.vim)
  标准模板子类定义范例
* [autoload/class/](autoload/class/)
  一些工具类定义都放在 class 子目录下
* [autoload/cmass/](autoload/cmass/)
  其他不是用于类定义的脚本，一般用于自定义命令实现
* [autoload/class/builder.vim](autoload/class/builder.vim) 
* [autoload/cmass/builder.vim](autoload/cmass/builder.vim)
  用于辅助生成自定义类代码
* [autoload/cmass/director.vim](autoload/cmass/director.vim)
  定义 ClassLoad ClassTest 命令
* [autoload/class/cmdlime.vim](autoload/class/cmdlime.vim)
  解析命令行选项工具，助于实现复杂功能的自定义命令
* [autoload/class/option/](autoload/class/option/)
  命令行选项的类定义
* [autoload/class/loger.vim](autoload/class/loger.vim)
  日志类定义，LogOn LogOff LogLevel LOG 等命令，增加简单方便的 echo 调试脚本的灵活性与实用性。

