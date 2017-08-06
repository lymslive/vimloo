" Class: class#viml#messager
" Author: lymslive
" Description: capture the vim command message output
" Create: 2017-02-28
" Modify: 2017-08-05

"LOAD:
if exists('s:load') && !exists('g:DEBUG')
    finish
endif

" CLASS:
let s:class = class#old()
let s:class._name_ = 'class#viml#messager'
let s:class._version_ = 1
let s:class.command = ''

function! class#viml#messager#class() abort "{{{
    return s:class
endfunction "}}}

" NEW:
function! class#viml#messager#new(...) abort "{{{
    let l:obj = class#new(s:class, a:000)
    return l:obj
endfunction "}}}

" CTOR:
function! class#viml#messager#ctor(this, ...) abort "{{{
    if a:0 > 0
        let a:this.command = a:1
    endif
endfunction "}}}

" ISOBJECT:
function! class#viml#messager#isobject(that) abort "{{{
    return class#isobject(s:class, a:that)
endfunction "}}}

" Capture: 
function! s:class.Capture(...) dict abort "{{{
    if a:0 > 0 && !empty(a:1)
        let self.command = a:1
    endif

    let l:sOut = ''
    try
        redir => l:sOut
        silent execute self.command
    finally
        redir END
    endtry
    
    return l:sOut
endfunction "}}}

" CaptureList: 
function! s:class.CaptureList(...) dict abort "{{{
    if a:0 > 0 && !empty(a:1)
        let l:sOut = self.Capture(a:1)
    else
        let l:sOut = self.Capture()
    endif

    if !empty(l:sOut)
        return split(l:sOut, "\n")
    else
        return []
    endif
endfunction "}}}

" LOAD:
let s:load = 1
:DLOG 'class#viml#messager is loading ...'
function! class#viml#messager#load(...) abort "{{{
    if a:0 > 0 && !empty(a:1) && exists('s:load')
        unlet s:load
        return 0
    endif
    return s:load
endfunction "}}}

" TEST:
function! class#viml#messager#test(...) abort "{{{
    if a:0 == 0
        :ELOG 'class#viml#messager#test need command argument'
        return
    endif
    let l:command = join(a:000)
    let l:obj = class#viml#messager#new(l:command)
    :LOG 'capture ' . l:command
    echo l:obj.Capture()

    let l:lsOutPut = l:obj.CaptureList()
    :LOG 'capture as list: ' . len(l:lsOutPut)
    echo l:lsOutPut

    return 0
endfunction "}}}
