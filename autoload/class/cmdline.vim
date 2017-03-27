" Class: class#cmdline
" Author: lymslive
" Description: command line option parser for custom command 
" Create: 2017-02-11
" Modify: 2017-03-27

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
let s:class.LastError = ''

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

" AddDash: allow - as an special argument, set it's meaning
function! s:class.AddDash(sDesc) dict abort "{{{
    call self.AddSingle('-', '-', a:sDesc)
endfunction "}}}
" SetDash: 
function! s:class.SetDash() dict abort "{{{
    call self.AddSingle('-', '-', 'special argument -')
    call self.Option['-'].SetValue()
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
function! s:class.AddGroup(sGroup, ...) dict abort "{{{
    for l:sOption in a:000 
        if !has_key(self.Option, l:sOption)
            :ELOG l:sOption . ' is not valid option, use long name'
            continue
        endif

        if has_key(self.Group, a:sGroup)
            call add(self.Group[a:sGroup], l:sOption)
        else
            let self.Group[a:sGroup] = [l:sOption]
        endif

        let self.Grouped[l:sOption] = a:sGroup
    endfor
    return 0
endfunction "}}}

" ParseCheck: 
function! s:class.ParseCheck(argv, ...) dict abort "{{{
    let l:bPostUnkown = v:false
    let l:iEnd = len(a:argv)
    if a:0 > 0
        let l:bPostUnkown = v:true
        if a:1 < l:iEnd
            let l:iEnd = a:1
        endif
    endif

    let l:idx = 0
    while l:idx < l:iEnd
        let l:sArg = a:argv[l:idx]
        let l:idx += 1

        " special arg
        if l:sArg ==# '?' || l:sArg ==# '-?'
            echo self.ShowUsage()
            return -1
        elseif l:sArg ==# '-'
            call self.DealDash()
            continue
        elseif l:sArg ==# '--'
            let self.LastParsed = '--'
            continue
        endif

        if self.LastParsed ==# '--'
            call add(self.PostArgv, l:sArg)
            continue
        endif

        let l:sDash = ''
        let l:sWord = ''
        let l:sArgPattern = '^\(-*\)\(.*\)'
        let l:lsMatch = matchlist(l:sArg, l:sArgPattern)
        if !empty(l:lsMatch)
            let l:sDash = l:lsMatch[1]
            let l:sWord = l:lsMatch[2]
        else
            :ELOG 'not valid argument'
            return -1
        endif

        let l:sOption = ''
        if empty(l:sDash)
            call self.DealArgument(l:sWord)
            continue
        elseif l:sDash ==# '--'
            let l:sOption = l:sWord
        elseif l:sDash ==# '-'
            let l:sOption = get(self.CharName, l:sWord[0], '')
        endif

        if empty(l:sOption) || !has_key(self.Option, l:sOption)
            if l:bPostUnkown
                call self.DealArgument(l:sArg)
                continue
            else
                echoerr 'unknown option: ' . l:sArg
                echo self.ShowUsage()
                return -1
            endif
        endif

        let l:jOption = self.Option[l:sOption]
        call self.DealOption(l:jOption)
        if l:sDash ==# '-'
            while len(l:sWord) > 1
                let l:sWord = l:sWord[1:]
                if !class#option#single#isobject(l:jOption)
                    call self.DealArgument(l:sWord)
                    break
                endif
                let l:sChar = l:sWord[0]
                let l:sOption = get(self.CharName, l:sChar, '')
                if empty(l:sOption) || !has_key(self.Option, l:sOption)
                    if l:bPostUnkown
                        call self.DealArgument('-' . l:sWord)
                        break
                    else
                        echoerr 'unknown option: ' . '-' . l:sWord
                        echo self.ShowUsage()
                        return -1
                    endif
                endif
                let l:jOption = self.Option[l:sOption]
                call self.DealOption(l:jOption)
            endwhile
        endif
    endwhile

    let l:iCount = self.GetLackNum()
    if l:iCount > 0
        echoerr 'have ' . l:iCount . ' option not provid argument'
        echo self.ShowUsage()
        return -1
    endif
endfunction "}}}

" DealOption: 
function! s:class.DealOption(jOption) dict abort "{{{
    if class#option#single#isobject(a:jOption)
        call a:jOption.SetValue()
        call self.OnGroupSet(a:jOption)
        let self.LastParsed = ''
    else
        let self.LastParsed= a:jOption.Name
    end
endfunction "}}}

" DealArgument: 
function! s:class.DealArgument(sArg) dict abort "{{{
    if empty(self.LastParsed)
        call add(self.PostArgv, a:sArg)
    else
        if self.LastParsed ==# '--'
            call add(self.PostArgv, a:sArg)
        endif
        let l:jOption = self.Option[self.LastParsed]
        if class#option#pairs#isobject(l:jOption)
            call l:jOption.SetValue(a:sArg)
            call self.OnGroupSet(l:jOption)
            let self.LastParsed = ''
        elseif class#option#multiple#isobject(l:jOption)
            call l:jOption.SetValue(a:sArg)
            call self.OnGroupSet(l:jOption)
        else
            echoerr 'dismatch option type'
            return -1
        endif
    endif
endfunction "}}}

" DealDash: a sole '-' can be option or arguent
function! s:class.DealDash() dict abort "{{{
    if has_key(self.Option, '-')
        let l:jOption = self.Option['-']
        if class#option#single#isobject(l:jOption)
            call l:jOption.SetValue()
            call self.OnGroupSet(l:jOption)
            let self.LastParsed= ''
        else
            let self.LastParsed= '-'
        end
    else
        call self.DealArgument('-')
    endif
endfunction "}}}

" OnGroupSet: Unset other options in the same group
function! s:class.OnGroupSet(jOption) dict abort "{{{
    let l:sOption = a:jOption.Name
    let l:sGroup = get(self.Grouped, l:sOption, '')
    if empty(l:sGroup) || !has_key(self.Group, l:sGroup)
        return 0
    endif

    let l:ljOption = self.Group[l:sGroup]
    for l:jOption in l:ljOption
        if l:jOption.Name !=# l:sOption
            call l:jOption.UnSet()
        endif
    endfor
endfunction "}}}

" HasGroup: which option in group has been set
" return the setted option name or empty string if none
function! s:class.HasGroup(sGroup) dict abort "{{{
    if empty(a:sGroup) || !has_key(self.Group, a:sGroup)
        return 0
    endif

    let l:ljOption = self.Group[a:sGroup]
    for l:jOption in l:ljOption
        if l:jOption.Has()
            return l:jOption.Name
        endif
    endfor

    return ''
endfunction "}}}

" GetGroup: get the value of setted option in group
function! s:class.GetGroup(sGroup) dict abort "{{{
    let l:sOption = self.HasGroup(a:sGroup)
    if empty(l:sOption)
        return ''
    else
        return self.Group[l:sOption].Value()
    endif
endfunction "}}}

" ExpectOption: 
function! s:class.ExpectOption() dict abort "{{{
    return empty(self.LastParsed)
endfunction "}}}

" StopOption: 
function! s:class.StopOption() dict abort "{{{
    return self.LastParsed ==# '--'
endfunction "}}}

" Has: 
function! s:class.Has(sName) dict abort "{{{
    return self.Option[a:sName].Has()
endfunction "}}}

" HasDash: 
function! s:class.HasDash() dict abort "{{{
    return self.Has('-')
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
        if l:sName ==# 'help' || l:sName ==# '--' || l:sName ==# '-'
            continue
        endif
        let l:sRet .= self.Option[l:sName].string(l:iMaxName) . "\n"
    endfor

    let l:sRet .= self.Option['help'].string(l:iMaxName) . "\n"
    let l:sRet .= self.Option['--'].string(l:iMaxName) . "\n"
    if has_key(self.Option, '-')
        let l:sRet .= self.Option['-'].string(l:iMaxName) . "\n"
    endif

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
    echo a:0
    for l:i in range(1, a:0)
        " echo a:1
        " echo a:2
        echo a:{l:i}
    endfor

    let l:jCmdLine = class#cmdline#new('CmdLineTest')
    call l:jCmdLine.AddSingle('a', 'aaa', 'some thing a')
    call l:jCmdLine.AddSingle('b', 'bbb', 'some thing b')
    call l:jCmdLine.AddPairs('c', 'ccc', 'some thing c')
    call l:jCmdLine.AddPairs('d', 'ddd', 'some thing d', 'default')
    call l:jCmdLine.ParseCheck(a:000)
    echo 'option[a] = ' . l:jCmdLine.Get('aaa')
    echo 'option[b] = ' . l:jCmdLine.Get('bbb')
    echo 'option[c] = ' . l:jCmdLine.Get('ccc')
    echo 'option[d] = ' . l:jCmdLine.Get('ddd')
    echo l:jCmdLine.GetPost()
    return 1
endfunction "}}}

