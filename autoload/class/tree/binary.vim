" Class: class#tree#binary
" Author: lymslive
" Description: VimL class frame
" Create: 2017-08-02
" Modify: 2017-08-03

"LOAD:
if exists('s:load') && !exists('g:DEBUG')
    finish
endif

" CLASS:
let s:class = class#old()
let s:class._name_ = 'class#tree#binary'
let s:class._version_ = 1

let s:class.parent = {}
let s:class.left = {}
let s:class.right = {}
let s:class.key_ = 0

function! class#tree#binary#class() abort "{{{
    return s:class
endfunction "}}}

" NEW:
function! class#tree#binary#new(...) abort "{{{
    let l:obj = copy(s:class)
    call l:obj._new_(a:000, 1)
    return l:obj
endfunction "}}}
" CTOR:
function! class#tree#binary#ctor(this, ...) abort "{{{
    let l:Suctor = s:class._suctor_()
    call l:Suctor(a:this)
endfunction "}}}

" ISOBJECT:
function! class#tree#binary#isobject(that) abort "{{{
    return s:class._isobject_(a:that)
endfunction "}}}

" LOAD:
let s:load = 1
:DLOG '-1 class#tree#binary is loading ...'
function! class#tree#binary#load(...) abort "{{{
    if a:0 > 0 && !empty(a:1) && exists('s:load')
        unlet s:load
        return 0
    endif
    return s:load
endfunction "}}}

" TEST:
function! class#tree#binary#test(...) abort "{{{
    return 0
endfunction "}}}
