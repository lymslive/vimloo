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

" group options that shield each other
let s:class.Group = {}
let s:class.Grouped = {}

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
    let a:this.PostArgv = []
    let a:this.CharName = {}
    let a:this.Group = {}
    let a:this.Grouped = {}

    call a:this.AddSingle('?', 'help', 'display this usage')
    call a:this.AddSingle('', '--', 'stop parse left options')
    let s:class.LastParsed = ''
endfunction "}}}

" NEW:
function! class#cmdline#new(...) abort "{{{
    let l:obj = copy(s:class)
    call l:obj._new_(a:000)
    return l:obj
endfunction "}}}

" AddSingle: 
function! s:class.AddSingle(sChar, sName, sDesc) dict abort "{{{
    if empty(a:sName)
        echoerr 'option name cannot be empty'
        rturn -1
    endif

    let l:jOption = class#option#single#new(a:sChar, a:sName, a:sDesc)
    let self.Option[a:sName] = l:jOption

    return self.MapName(a:sChar, a:sName)
endfunction "}}}

" AddPairs: 
function! s:class.AddPairs(sChar, sName, sDesc, ...) dict abort "{{{
    if a:0 == 0
        let l:jOption = class#option#pairs#new(a:sChar, a:sName, a:sDesc)
    else
        let l:jOption = class#option#pairs#new(a:sChar, a:sName, a:sDesc, a:1)
    endif

    let self.Option[a:sName] = l:jOption
    return self.MapName(a:sChar, a:sName)
endfunction "}}}

" AddMore: 
function! s:class.AddMore(sChar, sName, sDesc, ...) dict abort "{{{
    if a:0 == 0
        let l:jOption = class#option#multiple#new(a:sChar, a:sName, a:sDesc)
    else
        let l:jOption = class#option#multiple#new(a:sChar, a:sName, a:sDesc, a:1)
    endif

    let self.Option[a:sName] = l:jOption
    return self.MapName(a:sChar, a:sName)
endfunction "}}}

" SetDash: allow - as an special argument, set it's meaning
function! s:class.SetDash(sDesc) dict abort "{{{
    call a:this.AddSingle('-', 'DASH', a:sDesc)
endfunction "}}}

" MapName: map option short name to long name
function! s:class.MapName(sChar, sName) dict abort "{{{
    if empty(a:sChar)
        " sChar allow to be empty
        return 0
    endif

    if has_key(self.CharName, a:sChar)
        echom 'repeat option char: ' .  a:sChar
        return -1
    else
        let self.CharName[a:sChar] = a:sName
        return 0
    endif
endfunction "}}}

" AddGroup: add an existed option to a group
function! s:class.AddGroup(sGroup, sOption) dict abort "{{{
    if !has_key(self.Option, sOption)
        return -1
    endif

    if has_key(self.Group, sGroup)
        call add(self.Group[sGroup], sOption)
    else
        let self.Group[sGroup] = [sOption]
    endif

    let self.Grouped[sOption] = sGroup
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

        if self.ExpectOption()
            let l:iErr = self.ParseArg(l:arg)
            if l:iErr != 0
                return l:iErr
            endif
        else
            call self.Set(l:arg)
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

    " special argument - 
    if l:iArgLen == 1
        if has_key(self.Option, 'DASH')
            call self.Option.DASH.SetValue()
            return 0
        else
            :ELOG 'donot allow - argument, call SetDash() first'
            return -1
        endif
    endif

    " -- stop parser remain options
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

        if l:sName ==# 'help'
            echo self.ShowUsage()
            return -1
        endif

        let l:idx = l:idx + 1

        let l:iErr = self.Set(l:sName)
        if l:iErr != 0
            return l:iErr
        endif

        if !self.ExpectOption()
            break
        endif
    endwhile

    " tailed argument
    if l:idx < l:iend
        let l:sRest = a:arg[l:idx:]
        call self.Set(l:sRest)
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
        return -1
    endif

    if l:sName ==# 'help'
        echo self.ShowUsage()
        return -1
    endif

    return self.Set(l:sName)
endfunction "}}}

" ExpectOption: 
function! s:class.ExpectOption() dict abort "{{{
    return empty(self.LastParsed)
endfunction "}}}

" Set: feed a arg as option name or it's argument
function! s:class.Set(sArg) dict abort "{{{
    if self.ExpectOption()
        if has_key(self.Option, a:sArg)
            let l:jOption = self.Option[l:sName]
        else
            echoerr 'unkown option: ' . a:arg
            return -1
        endif
        if class#option#single#isobject(l:jOption)
            call l:jOption.SetValue()
        else
            let self.LastParsed= a:sArg
        end
    else
        if self.LastParsed ==# '--'
            call add(self.PostArgv, a:sArg)
        endif
        let l:jOption = self.Option[self.LastParsed]
        if class#option#pairs#isobject(l:jOption)
            call l:jOption.SetValue(get(a:000, 0, ''))
            let self.LastParsed = ''
        elseif class#option#multiple#isobject(l:jOption)
            call l:jOption.SetValue(get(a:000, 0, ''))
        else
            echoerr 'dismatch option type'
            return -1
        endif
    endif

    return 0
endfunction "}}}

" Has: 
function! s:class.Has(sName) dict abort "{{{
    return self.Option[a:sName].Has()
endfunction "}}}

" HasDash: 
function! s:class.HasDash() dict abort "{{{
    return self.Has('DASH')
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
        if l:sName ==# 'help' || l:sName ==# '--' || l:sName ==# 'DASH'
            continue
        endif
        let l:sRet .= self.Option[l:sName].string(l:iMaxName) . "\n"
    endfor

    if has_key(self.Option, 'DASH')
        let l:sRet .= self.Option['DASH'].string(l:iMaxName) . "\n"
    endif
    let l:sRet .= self.Option['--'].string(l:iMaxName) . "\n"
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
:DLOG 'class#cmdline loading ...'

" TEST:
function! class#cmdline#test(...) abort "{{{
    " :ClassTest -- -ac xyz -d efg
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

