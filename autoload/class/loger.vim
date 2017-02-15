" Class: class#loger
" Author: lymslive
" Description: VimL class frame
" Create: 2017-02-15
" Modify: 2017-02-15

"LOAD:
if exists('s:load') && !exists('g:DEBUG')
    finish
endif

" BASIC:
let s:class = class#old()
let s:class._name_ = 'class#loger'
let s:class._version_ = 1

" the log file :redir to
let s:class.LogFile = ''
" the min level of message that will loged by Echo method
let s:class.LogLevel = 0

function! class#loger#class() abort "{{{
    return s:class
endfunction "}}}

" CTOR:
function! class#loger#ctor(this, argv) abort "{{{
    if len(a:argv) > 0 && !empty(a:argv[0])
        let a:this.LogFile = a:argv[0]
    endif
endfunction "}}}

" NEW:
function! class#loger#new(...) abort "{{{
    let l:obj = copy(s:class)
    call l:obj._new_(a:000)
    return l:obj
endfunction "}}}

" INSTANCE:
let s:instance = {}
function! class#loger#instance() abort "{{{
    if empty(s:instance)
        let s:instance = class#new('class#loger')
    endif
    return s:instance
endfunction "}}}

" SetLogFile: 
function! class#loger#SetLogFile(pFileName) abort "{{{
    let l:instance = class#loger#instance()
    let l:instance.LogFile = a:pFileName
    if !empty(a:pFileName)
        :execute 'redir >> ' . a:pFileName
    else
        :redir END
    endif
endfunction "}}}

" SetLogLevel: 
function! class#loger#SetLogLevel(iLevel) abort "{{{
    let l:instance = class#loger#instance()
    let l:instance.LogLevel = 0 + a:iLevel
endfunction "}}}

" Echo: 
function! s:class.Echo(sMessage, iLevel, sHighlight) dict abort "{{{
    if a:iLevel < self.LogLevel
        return 0
    endif

    if !empty(a:sHighlight)
        :execute 'echohl ' . a:sHighlight
    endif

    echo a:sMessage

    if !empty(a:sHighlight)
        :echohl None
    endif
endfunction "}}}

" Log: 
" may have two option in the leading string: -n -HighName
function! class#loger#hLog(sMessage) abort "{{{
    let l:instance = class#loger#instance()

    let l:iMsgLen = len(a:sMessage)
    if l:iMsgLen <= 0
        return 0
    endif

    if a:sMessage[0] != '-'
        call l:instance.Echo(a:sMessage, 0, '')
        return 0
    endif

    " parse leading option
    let l:iLevel = 0
    let l:sHighlight = ''
    let l:lsMatch = matchlist(a:sMessage, '^\(-[0-9A-Za-z]\+\)\?\s*\(-[0-9A-Za-z]\+\)\?\s*\(.*\)')
    if empty(l:lsMatch)
        return 0
    endif

    " echo 'LOG with option: ' . l:lsMatch[1] . ' ' . l:lsMatch[2]

    if !empty(l:lsMatch[1])
        let l:sOption = strpart(l:lsMatch[1], 1)
        if match(l:sOption, '^[0-9]\+') != -1
            let l:iLevel = 0 + l:sOption
        else
            let l:sHighlight = l:sOption
        endif
    endif

    if !empty(l:lsMatch[2])
        let l:sOption = strpart(l:lsMatch[2], 1)
        if match(l:sOption, '^[0-9]\+') != -1
            let l:iLevel = 0 + l:sOption
        else
            let l:sHighlight = l:sOption
        endif
    endif

    " echo 'l:iLevel = ' . l:iLevel . '; l:sHighlight = ' . l:sHighlight

    let l:sMessage = l:lsMatch[3]
    call l:instance.Echo(l:sMessage, l:iLevel, l:sHighlight)
    return 0
endfunction "}}}

" LOAD:
let s:load = 1
echo 'class#loger is loading ...'
function! class#loger#load(...) abort "{{{
    if a:0 > 0 && !empty(a:1) && exists('s:load')
        unlet s:load
        return 0
    endif
    return s:load
endfunction "}}}

" TEST:
function! class#loger#test(...) abort "{{{
    :LogOn test.log
    :LogLevel 0
    :LOG 'literatur string'
    let l:str = 'a string variable'
    :LOG l:str
    :LOG 'literatur string concatente with ' . l:str
    :LOG '-WarningMsg ' . l:str
    :LogLevel 2
    :LOG '-WarningMsg L0 ' . l:str
    :LOG '-1 -WarningMsg L1 ' . l:str
    :LOG '-WarningMsg -2 L2 ' . l:str
    :LOG '-WarningMsg -3 L3 ' . l:str
    :LogOff
    return 0
endfunction "}}}
