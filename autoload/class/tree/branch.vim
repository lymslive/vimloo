" Class: class#tree#branch
" Author: lymslive
" Description: a tree with many children
" Create: 2017-08-02
" Modify: 2017-08-03

"LOAD:
if exists('s:load') && !exists('g:DEBUG')
    finish
endif

" CLASS:
let s:class = class#old()
let s:class._name_ = 'class#tree#branch'
let s:class._version_ = 1

let s:class.parent = {}
let s:class.children = {}
let s:class.key_ = 0

function! class#tree#branch#class() abort "{{{
    return s:class
endfunction "}}}

" NEW:
function! class#tree#branch#new(...) abort "{{{
    let l:obj = copy(s:class)
    call l:obj._new_(a:000, 1)
    return l:obj
endfunction "}}}
" CTOR:
function! class#tree#branch#ctor(this, ...) abort "{{{
    let l:Suctor = s:class._suctor_()
    call l:Suctor(a:this)
endfunction "}}}

" ISOBJECT:
function! class#tree#branch#isobject(that) abort "{{{
    return s:class._isobject_(a:that)
endfunction "}}}

" LOAD:
let s:load = 1
:DLOG '-1 class#tree#branch is loading ...'
function! class#tree#branch#load(...) abort "{{{
    if a:0 > 0 && !empty(a:1) && exists('s:load')
        unlet s:load
        return 0
    endif
    return s:load
endfunction "}}}

" TEST:
function! class#tree#branch#test(...) abort "{{{
    return 0
endfunction "}}}
