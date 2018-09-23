# VimL 脚本通用工具库收集

## `jp#` 日本 vim 社区的 vital.vim

源于这里：https://github.com/vim-jp/vital.vim

我将 vital 的模块稍作整理，重置于 `jp#` 命名空间之下。这是日本 `japanese` 的缩
写；如果懂汉语拼音的话，也可读作极品 `jiping` 。

### 所作调整只有：

* 将依赖引用其他模块的语句，改用 `package#import()` 函数按 `#` 化的标准路径引
  入。基本只涉及发动部分模块的前面几行，不影响具体功能的实现。
* 将其明确标记为 `Deprecated` 的剔除，不再跟踪维护。
* 测试目录 `test/` 为了能重跑，也将导入模块的语句调整。按 vital 原来使用的测试
  框架，需要用到 [thinca/vim-themis](https://github.com/thinca/vim-themis) 。

### 使用方法

只要下载仓库的目录加入 vim 的 `&rtp` 路径，可在任意 VimL 脚本中按标准路径导入
`jp#` 库，如：

```vim
let L = package#import('jp#Data#List')
call L.pop()
```

也可以在插件中先建立本地包管理对象，用略短的相对路径导入，如：
```vim
let V = package#new('near compatible to vital', 'jp')
let V = package#new('jp')
let L = V.import('Data.List')
call L.pop()
```

上面两句 `package#new()` 调用几乎等效，因为对象的名字不重要，重要的是路径。

`vital` 原来的惯用做法，是提供另一个命令，将所需的部分模块（及其引用的模块）安
装（也就是复制）到各做插件中，同时也在每个安装的模块文件头部，自动生成一些必要
的导出代码。虽然据说这能使各插件保持独立，解耦，但个人认为这造成了很大的冗余。
如果你安装他们的插件套餐，vim 运行时就得重复加载那些内容功能相同只是位置路径不
一样的脚本。

这里的 `package.vim` 提供一种全局共享的思路，让每个工具模块组织下标准的 `#` 命
名空间之下，而日本社区的 vital 正归于 `jp#` 命名空间下。但是也依然提供使用对象
的方法来管理特定插件目录下的模块，不论是自己新写的，还是从其他地方拷过来的。

