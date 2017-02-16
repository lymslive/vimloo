" Class: class#cmdline
" Author: lymslive
" Description: VimL class frame
" Create: 2017-02-11
" Modify: 2017-02-11

"LOAD:
if exists('s:load') && !exists('g:DEBUG')
    finish
endif

" BASIC:
let s:class = class#old()
let s:class._name_ = 'class#cmdline'
let s:class._version_ = 1

" command name
let s:class.Command = ''

" Support what options
let s:class.Option = {}
" position argument without option after parsed
let s:class.PostArgv = []

" lookup dict, option short name (-x) => long name (--xname)
let s:class.CharName = {}

" tow list of single option names that set/unset each other, such as
" -x and -X, --bar and --nobar, --barOn and -barOff
let s:class.SwitchOn = []
let s:class.SwitchOff = []

" for algorithm popurse, save last parsed option name
let s:class.LastParsed = ''

function! class#cmdline#class() abort "{{{
    return s:class
endfunction "}}}

" CTOR:
function! class#cmdline#ctor(this, argv) abort "{{{
    if len(a:argv) > 0
        let a:this.Command = a:argv[0]
    endif

    " list or dict member must be re-init
    let a:this.Option = {}
    let a:this.CharName = {}
    let a:this.SwitchOn = []
    let a:this.SwitchOff = []
    let a:this.PostArgv = []

    call a:this.AddSingle('?', 'help', 'display this usage')
endfunction "}}}

" NEW:
function! class#cmdline#new(...) abort "{{{
    let l:obj = copy(s:class)
    call l:obj._new_(a:000)
    return l:obj
endfunction "}}}

" AddSingle: 
function! s:class.AddSingle(sChar, sName, sDesc) dict abort "{{{
    let l:jOption = class#option#single#new(a:sChar, a:sName, a:sDesc)
    let self.Option[a:sName] = l:jOption

    if has_key(self.CharName, a:sChar)
        echom 'repeat option char: ' .  a:sChar
        return -1
    else
        let self.CharName[a:sChar] = a:sName
    endif
    return 0
endfunction "}}}

" AddPairs: 
function! s:class.AddPairs(sChar, sName, sDesc, ...) dict abort "{{{
    if a:0 == 0
        let l:jOption = class#option#pairs#new(a:sChar, a:sName, a:sDesc)
    else
        let l:jOption = class#option#pairs#new(a:sChar, a:sName, a:sDesc, a:1)
    endif
    let self.Option[a:sName] = l:jOption

    if has_key(self.CharName, a:sChar)
        echom 'repeat option char: ' .  a:sChar
        return -1
    else
        let self.CharName[a:sChar] = a:sName
    endif

    return 0
endfunction "}}}

" AddSwitch: make two option switch off each other
" sNameOn and sNameOff must are already added single options
" if a:1 is ture, 
" sNameOn option is default set, otherwise sNameOff is default set
function! s:class.AddSwitch(sNameOn, sNameOff, ...) dict abort "{{{
    call add(self.SwitchOn, a:sNameOn)
    call add(self.SwitchOn, a:sNameOff)
    if a:0 > 0
        if a:1
            let self.Option[a:sNameOn].Set = v:true
            let self.Option[a:sNameOff].Set = v:false
        else
            let self.Option[a:sNameOn].Set = v:false
            let self.Option[a:sNameOff].Set = v:true
        endif
    endif
    return 0
endfunction "}}}

" Check: parse and check the input argv
" return some error number, 0 as success
function! s:class.Check(argv) dict abort "{{{
    for l:arg in a:argv
        if l:arg ==# '?' || l:arg ==# '-?'
            echo self.ShowUsage()
            return -1
        endif

        if !empty(self.LastParsed)
            if self.LastParsed !=# '--'
                call self.Option[self.LastParsed].SetValue(l:arg)
                let self.LastParsed = ''
            else
                call add(self.PostArgv, l:arg)
            endif
        else
            let l:iErr = self.ParseArg(l:arg)
            if l:iErr != 0
                return l:iErr
            endif
        endif
    endfor

    if !empty(self.LastParsed) && self.LastParsed !=# '--'
        echom 'the last option has not argument: --' . self.LastParsed
        return 3
    endif

    let l:iCount = self.GetLackNum()
    if l:iCount > 0
        echom 'have ' . l:iCount . ' option not provid argument'
        echo self.ShowUsage()
        return 4
    endif

    return 0
endfunction "}}}

" ParseArg: parse each input argument
" return some error number, 0 as success
function! s:class.ParseArg(arg) dict abort "{{{
    let l:iArgLen = len(a:arg)

    if l:iArgLen == 0
        return 0
    endif

    if a:arg[0] != '-'
        call add(self.PostArgv, a:arg)
        return 0
    endif

    " special argument - or -- stop parser remain options
    if l:iArgLen == 1
        let self.LastParsed = '--'
        return 0
    endif

    if l:iArgLen == 2 && a:arg ==# '--'
        let self.LastParsed = '--'
        return 0
    endif

    if a:arg[1] == '-'
        return self.ParseLongOption(a:arg[2:])
    else
        return self.ParseShortOption(a:arg[1:])
    endif
endfunction "}}}

" ParseShortOption: -o, 
" may combined -xyz, 
" the last part may be argument of the previous option
" a:arg input have - removed
function! s:class.ParseShortOption(arg) dict abort "{{{
    let l:iend = len(a:arg)
    let l:idx = 0
    while l:idx < l:iend
        let l:sChar = a:arg[l:idx]
        if has_key(self.CharName, l:sChar)
            let l:sName = self.CharName[l:sChar]
        else
            let l:sName = ''
            echom 'option char not supported: -' . l:sChar
            return 1
        endif

        if has_key(self.Option, l:sName)
            let l:jOption = self.Option[l:sName]
        else
            echom 'unkown option: ' . a:arg
            return 2
        endif

        let l:idx = l:idx + 1
        if class#option#single#isobject(l:jOption)
            call l:jOption.SetValue()
        else
            let self.LastParsed = l:sName
            break
        endif

        if l:sName ==# 'help'
            echo self.ShowUsage()
            return -1
        endif
    endwhile

    if l:idx < l:iend
        if !empty(self.LastParsed)
            let l:sRest = a:arg[l:idx:]
            call self.Option[self.LastParsed].SetValue(l:sRest)
            let self.LastParsed = ''
        endif
    endif

    return 0
endfunction "}}}

" ParseLongOption: --option
" just option long name, the next wll follow it's argument
" a:arg input have -- removed
function! s:class.ParseLongOption(arg) dict abort "{{{
    let l:sName = a:arg

    if has_key(self.Option, l:sName)
        let l:jOption = self.Option[l:sName]
    else
        echom 'unkown option: ' . a:arg
        return 2
    endif

    if class#option#single#isobject(l:jOption)
        call l:jOption.SetValue()
    else
        let self.LastParsed = l:sName
    endif

    if l:sName ==# 'help'
        echo self.ShowUsage()
        return -1
    endif

    return 0
endfunction "}}}

" Has: 
function! s:class.Has(sName) dict abort "{{{
    return self.Option[a:sName].Has()
endfunction "}}}

" Get: 
function! s:class.Get(sName) dict abort "{{{
    return self.Option[a:sName].Value()
endfunction "}}}

" GetPost: 
function! s:class.GetPost() dict abort "{{{
    return self.PostArgv
endfunction "}}}

" GetLackNum: how many options that haven't provided argument, and also no default
function! s:class.GetLackNum() dict abort "{{{
    let l:iCount = 0
    for [l:sName, l:jOption] in items(self.Option)
        if class#option#pairs#isobject(l:jOption)
                    \ && l:jOption.Must() && !l:jOption.Has()
            let l:iCount = l:iCount + 1
            echom 'option requires argument: --' . l:sName
        endif
        unlet l:sName 
    endfor

    return l:iCount
endfunction "}}}

" ShowUsage: 
function! s:class.ShowUsage() abort "{{{
    let l:lsKeyName = keys(self.Option)
    call sort(l:lsKeyName)

    let l:iMaxName = 0
    for l:sName in l:lsKeyName
        let l:iNameLen = len(l:sName)
        if l:iNameLen > l:iMaxName
            let l:iMaxName = l:iNameLen
        endif
    endfor

    let l:sRet = 'usage: ' . self.Command . " [options] ...\n"
    for l:sName in l:lsKeyName
        if l:sName ==# 'help'
            continue
        endif
        let l:sRet .= self.Option[l:sName].string(l:iMaxName) . "\n"
    endfor

    let l:sRet .= self.Option['help'].string(l:iMaxName) . "\n"

    return l:sRet
endfunction "}}}

" LOAD:
let s:load = 1
function! class#cmdline#load(...) abort "{{{
    if a:0 > 0 && !empty(a:1) && exists('s:load')
        unlet s:load
        return 0
    endif
    return s:load
endfunction "}}}
echo 'class#cmdline loading ...'

" TEST:
function! class#cmdline#test(...) abort "{{{
    let l:jCmdLine = class#cmdline#new('CmdLineTest')
    call l:jCmdLine.AddSingle('a', 'aaa', 'some thing a')
    call l:jCmdLine.AddSingle('b', 'bbb', 'some thing b')
    call l:jCmdLine.AddPairs('c', 'ccc', 'some thing c')
    call l:jCmdLine.AddPairs('d', 'ddd', 'some thing d', 'default')
    call l:jCmdLine.Check(a:000)
    echo 'option[a] = ' . l:jCmdLine.Get('aaa')
    echo 'option[b] = ' . l:jCmdLine.Get('bbb')
    echo 'option[c] = ' . l:jCmdLine.Get('ccc')
    echo 'option[d] = ' . l:jCmdLine.Get('ddd')
    echo l:jCmdLine.GetPost()
    return 1
endfunction "}}}

