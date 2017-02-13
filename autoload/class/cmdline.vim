" Class: class#cmdline
" Author: lymslive
" Description: VimL class frame
" Create: 2017-02-11
" Modify: 2017-02-11

" BASIC:
let s:class = class#old()
let s:class._name_ = 'class#cmdline'
let s:class._version_ = 1

" Input argument list 
let s:class.Argc = 0
let s:class.Argv = []

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
    a:this.Argv = a:argv
    a:this.Argc = leng(a:argv)
    a:this.Option = {}
    a:this.CharName = {}
    a:this.SwitchOn = []
    a:this.SwitchOff = []
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

    if has_key(self.CharName)
        echoerr 'repeat option char: ' .  sChar
    else
        let self.CharName[a:sChar] = sName
    endif
endfunction "}}}

" AddPairs: 
function! s:class.AddPairs(sChar, sName, sDesc, ...) dict abort "{{{
    if a:0 == 0
        let l:jOption = class#option#pairs#new(a:sChar, a:sName, a:sDesc)
    else
        let l:jOption = class#option#pairs#new(a:sChar, a:sName, a:sDesc, a:1)
    endif
    let self.Option[a:sName] = l:jOption

    if has_key(self.CharName)
        echoerr 'repeat option char: ' .  sChar
    else
        let self.CharName[a:sChar] = sName
    endif
endfunction "}}}

" AddSwitch: make two option switch off each other
" sNameOn and sNameOff must are already added single options
" if a:1 is ture, 
" sNameOn option is default set, otherwise sNameOff is default set
function! s:class.AddSwitch(sNameOn, sNameOff, ...) dict abort "{{{
    call add(self.SwitchOn, sNameOn)
    call add(self.SwitchOn, sNameOff)
    if a:0 > 0
        if a:1
            let self.Option[a:sNameOn].Set = v:ture
            let self.Option[a:sNameOff].Set = v:false
        else
            let self.Option[a:sNameOn].Set = v:false
            let self.Option[a:sNameOff].Set = v:ture
        endif
    endif
endfunction "}}}

" Check: parse and check the input argv
" return some error number, 0 as success
function! s:class.Check() dict abort "{{{
    for l:arg in self.Argv
        if !empty(slef.LastParsed)
            let self.Option[self.LastParsed].Argument = l:arg
            let self.LastParsed = ''
        else
            let l:iErr = self.ParseArg(l:arg)
            if l:iErr != 0
                return l:iErr
            endif
        endif
    endfor

    if !empty(slef.LastParsed)
        echoerr 'the last option has not argument: --' . self.LastParsed
        return 3
    endif

    let l:iCount = self.GetLackNum()
    if l:iCount > 0
        echoerr 'have ' . l:iCount . ' option not provid argument'
        return 4
    endif

    return 0
endfunction "}}}

" ParseArg: parse each input argument
" return some error number, 0 as success
function! s:class.ParseArg(arg) dict abort "{{{
    if a:arg[0] != '-'
        call add(self.PostArgv, a:arg)
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
            echoerr 'option char not supported: -' . l:sChar
            return 1
        endif

        if has_key(self.Option, l:sName)
            let l:jOption = self.Option[l:sName]
        else
            echoerr 'unkown option: ' . a:arg
            return 2
        endif

        let l:idx = l:idx + 1
        if l:jOption._name_ ==# 'class#option#single'
            l:jOption.Set = v:ture
        else
            let self.LastParsed = l:sName
            break
        endif
    endwhile

    if l:idx < l:iend
        if !empty(self.LastParsed)
            let l:sRest = a:arg[l:idx:]
            let self.Option[self.LastParsed].Argument = l:sRest
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
        echoerr 'unkown option: ' . a:arg
        return 2
    endif

    if l:jOption._name_ ==# 'class#option#single'
        let l:jOption.Set = v:ture
    else
        let self.LastParsed = l:sName
    endif

    return 0
endfunction "}}}

" Has: 
function! s:class.Has(sName) dict abort "{{{
    return self.Option[sName].Has()
endfunction "}}}

" Get: 
function! s:class.Get(sName) dict abort "{{{
    return self.Option[sName].Value()
endfunction "}}}

" GetPost: 
function! s:class.GetPost() dict abort "{{{
    return self.PostArgv
endfunction "}}}

" GetLackNum: how many options that haven't provided argument, and also no default
function! s:class.GetLackNum() dict abort "{{{
    let l:iCount = 0
    for [l:sName, l:jOption] in items(self.Option)
        if l:jOption._name_ ==# 'class#option#pairs' && l:jOption.Must() && empty(l:jOption.Argument)
            let l:iCount = l:iCount + 1
            echoerr 'option requires argument: --' . l:sName
        endif
        unlet l:sName 
    endfor

    return l:iCount
endfunction "}}}

" LOAD:
function! class#cmdline#load() abort "{{{
    return 1
endfunction "}}}

" TEST:
function! class#cmdline#test() abort "{{{
    return 1
endfunction "}}}

