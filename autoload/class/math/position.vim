" Class: class#math#position
" Author: lymslive
" Description: like point(x, y) but used as (row, col), more like point(y, x)
" Create: 2017-07-06
" Modify: 2017-07-06

"LOAD:
if exists('s:load') && !exists('g:DEBUG')
    finish
endif

" CLASS:
let s:class = class#old()
let s:class._name_ = 'class#math#position'
let s:class._version_ = 1

let s:class.row = 0
let s:class.col = 0

function! class#math#position#class() abort "{{{
    return s:class
endfunction "}}}

" NEW: #new(row, col)
function! class#math#position#new(...) abort "{{{
    if a:0 < 2 || type(a:1) != type(0) || type(a:2) != type(0)
        :ELOG 'please new position(row, col)'
        return v:none
    endif

    let l:obj = copy(s:class)
    call l:obj._new_(a:000, 1)
    return l:obj
endfunction "}}}
" CTOR:
function! class#math#position#ctor(this, row, col) abort "{{{
    let a:this.row = a:row
    let a:this.col = a:col
endfunction "}}}

" ISOBJECT:
function! class#math#position#isobject(that) abort "{{{
    return s:class._isobject_(a:that)
endfunction "}}}

" LOAD:
let s:load = 1
:DLOG '-1 class#math#position is loading ...'
function! class#math#position#load(...) abort "{{{
    if a:0 > 0 && !empty(a:1) && exists('s:load')
        unlet s:load
        return 0
    endif
    return s:load
endfunction "}}}

" TEST:
function! class#math#position#test(...) abort "{{{
    return 0
endfunction "}}}
