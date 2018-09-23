" Class: class#viml#loger
" Author: lymslive
" Description: VimL class frame
" Create: 2017-02-15
" Modify: 2018-09-22

" BASIC:
let s:class = class#old()
let s:class._name_ = 'class#viml#loger'
let s:class._version_ = 2

" the log file :redir to
" Special '%' to current buffer, '%n' to buffer n
let s:class.LogFile = ''
" the min level of message that will loged by Echo method
let s:class.LogLevel = 0
" the default highlight
let s:class.Highlight = 'Comment'

let s:LOGLEVEL = {}
let s:LOGLEVEL.ERROR = 0
let s:LOGLEVEL.DEBUG = 1
let s:LOGLEVEL.WARN = 2
let s:LOGLEVEL.INFO = 3

function! class#viml#loger#class() abort "{{{
    return s:class
endfunction "}}}

" CTOR:
function! class#viml#loger#ctor(this, ...) abort "{{{
    if a:0 > 0 && !empty(a:1)
        let a:this.LogFile = a:1
    endif
endfunction "}}}

" NEW:
function! class#viml#loger#new(...) abort "{{{
    let l:obj = class#new(s:class, a:000)
    return l:obj
endfunction "}}}

" log
function! s:class.log(sMessage, iLevel, sHighlight) dict abort "{{{
    " only set log level
    if empty(a:sMessage) && a:iLevel != self.LogLevel
        return self.log_level(a:iLevel)
    endif

    if empty(a:sMessage) && a:sHighlight != self.Highlight
        return self.log_style(a:sHighlight)
    endif

    if empty(a:sMessage) || a:iLevel > self.LogLevel
        return
    endif

    if empty(self.LogFile)
        try
            if !empty(a:sHighlight)
                let l:sHighlight = a:sHighlight
            else
                let l:sHighlight = self.Highlight
            endif
            :execute 'echohl ' . l:sHighlight
            echomsg string(a:sMessage)
        catch 
        finally 
            echohl None
        endtry
        return
    endif

    if self.LogFile[0] != '%'
        try
            :execute 'redir >> ' . self.LogFile
            echomsg string(a:sMessage)
            :redir END
        catch 
        finally 
            :redir END
        endtry
    elseif self.LogFile == '%'
        call append('$', a:sMessage)
        " $print
    else
        let l:bufnr = matchstr(self.LogFile, '^%\zs\d\+\ze')
        if !empty(l:bufnr)
            call appendbufline(0+l:bufnr, '$', a:sMessage)
        else
            echoerr 'log buffer not exists: ' . self.LogFile
        endif
    endif
endfunction "}}}

" log_file: 
function! s:class.log_file(...) dict abort "{{{
    if a:0 == 0
        return self.LogFile
    endif

    if type(a:1) != type('') && type(a:1) != type(0)
        echoerr 'Invalid log file argument'
        return
    endif

    let l:sNewFile = a:1
    let l:sOldFile = self.LogFile
    let self.LogFile = l:sNewFile
    if !empty(l:sOldFile) && !empty(l:sNewFile)
        echo 'change log file: ' . s:Absolute(l:sOldFile) . ' --> ' . s:Absolute(l:sNewFile)
    elseif !empty(l:sOldFile) && empty(l:sNewFile)
        echo 'stop log file: ' . s:Absolute(l:sOldFile)
    elseif empty(l:sOldFile) && !empty(l:sNewFile)
        echo 'start log file: ' . s:Absolute(l:sNewFile)
    endif

    return l:sOldFile
endfunction "}}}

" log_level: 
function! s:class.log_level(...) dict abort "{{{
    if a:0 == 0
        return self.LogLevel
    endif

    if type(a:1) != type(0)
        echoerr 'Invalid log level argument'
        return
    endif

    let l:iLevel = self.LogLevel
    let self.LogLevel = a:1
    return l:iLevel
endfunction "}}}

" log_style: 
function! s:class.log_style(...) dict abort "{{{
    if a:0 == 0
        return self.Highlight
    endif

    if type(a:1) != type('')
        echoerr 'Invalid log style(highlight) argument'
        return
    endif

    let l:sHighlight = self.Highlight
    let self.Highlight = a:1
    return l:sHighlight
endfunction "}}}

" INSTANCE:
function! s:instance() abort "{{{
    if !exists('s:instance_') || empty(s:instance_)
        let s:instance_ = class#new('class#viml#loger')
    endif
    return s:instance_
endfunction "}}}

function! s:log(...) abort "{{{
    let l:instance = s:instance()
    return a:0 == 0 ? l:instance.log() : l:instance.log(a:1)
endfunction "}}}
function! s:log_file(...) abort "{{{
    let l:instance = s:instance()
    return a:0 == 0 ? l:instance.log_file() : l:instance.log_file(a:1)
endfunction "}}}
function! s:log_level(...) abort "{{{
    let l:instance = s:instance()
    return a:0 == 0 ? l:instance.log_level() : l:instance.log_level(a:1)
endfunction "}}}
function! s:log_style(...) abort "{{{
    let l:instance = s:instance()
    return a:0 == 0 ? l:instance.log_style() : l:instance.log_style(a:1)
endfunction "}}}

" Absolute: 
function! s:Absolute(sPath) abort "{{{
    if a:sPath =~ '^/'
        return a:sPath
    else
        return simplify(getcwd() . '/' . a:sPath)
    endif
endfunction "}}}

" export: 
function! class#viml#loger#export() abort "{{{
    if !exists('s:EXPORT') || empty(s:EXPORT)
        let s:EXPORT = {}
        let s:EXPORT.new = function('class#viml#loger#new')
        let s:EXPORT.instance = function('s:instance')
    endif
    return s:EXPORT
endfunction "}}}

" LOAD:
function! class#viml#loger#load(...) abort "{{{
    return 1
endfunction "}}}

" TEST:
function! class#viml#loger#test(...) abort "{{{
    return 0
endfunction "}}}
