" Class: sample#base
" Author: lymslive
" Description: VimL class frame
" Create: 2017-02-20
" Modify: 2017-02-20

" CLASS:
let s:class = class#old()
let s:class._name_ = 'sample#base'
let s:class._version_ = 1

let s:class.baseProperty = 'baseProperty'

function! sample#base#class() abort "{{{
    return s:class
endfunction "}}}

" NEW:
function! sample#base#new(...) abort "{{{
    let l:obj = copy(s:class)
    call l:obj._new_(a:000)
    return l:obj
endfunction "}}}

" CTOR:
function! sample#base#ctor(this, argv) abort "{{{
    if len(a:argv) > 0
        let a:this.baseProperty = a:argv[0]
    endif
endfunction "}}}

" BaseMethod: 
function! s:class.BaseMethod() dict abort "{{{
    echo 'calling BaseMethod()'
    return self.baseProperty
endfunction "}}}

" ISOBJECT:
function! sample#base#isobject(that) abort "{{{
    return s:class._isobject_(a:that)
endfunction "}}}
function! sample#base#isa(that) abort "{{{
    return s:class._isa_(a:that)
endfunction "}}}

echo 'sample#base is loading'

" TEST:
function! sample#base#test(...) abort "{{{
    return 0
endfunction "}}}
