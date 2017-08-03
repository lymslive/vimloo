" Class: class#tree#file
" Author: lymslive
" Description: file system tree
" Create: 2017-08-02
" Modify: 2017-08-03

"LOAD:
if exists('s:load') && !exists('g:DEBUG')
    finish
endif

" CLASS:
let s:class = class#tree#branch#old()
let s:class._name_ = 'class#tree#file'
let s:class._version_ = 1

let s:class.name = ''
let s:class.size = 0
let s:class.type = ''
let s:class.time = 0
let s:class.perm = ''

function! class#tree#file#class() abort "{{{
    return s:class
endfunction "}}}

" NEW:
function! class#tree#file#new(...) abort "{{{
    let l:obj = copy(s:class)
    call l:obj._new_(a:000, 1)
    return l:obj
endfunction "}}}
" CTOR:
function! class#tree#file#ctor(this, ...) abort "{{{
    let l:Suctor = s:class._suctor_()
    call l:Suctor(a:this)
endfunction "}}}

" ISOBJECT:
function! class#tree#file#isobject(that) abort "{{{
    return s:class._isobject_(a:that)
endfunction "}}}

" LOAD:
let s:load = 1
:DLOG '-1 class#tree#file is loading ...'
function! class#tree#file#load(...) abort "{{{
    if a:0 > 0 && !empty(a:1) && exists('s:load')
        unlet s:load
        return 0
    endif
    return s:load
endfunction "}}}

" TEST:
function! class#tree#file#test(...) abort "{{{
    return 0
endfunction "}}}
