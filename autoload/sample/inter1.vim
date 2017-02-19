" Class: sample#inter1
" Author: lymslive
" Description: VimL class frame
" Create: 2017-02-20
" Modify: 2017-02-20

" CLASS:
let s:class = class#old()
let s:class._name_ = 'sample#inter1'
let s:class._version_ = 1

function! sample#inter1#class() abort "{{{
    return s:class
endfunction "}}}

" InterFuncA1: 
function! s:class.InterFuncA1() dict abort "{{{
    echo 'calling InterFuncA1 of sample#inter1'
endfunction "}}}
" InterFuncB1: 
function! s:class.InterFuncB1() dict abort "{{{
    echo 'calling InterFuncB1 of sample#inter1'
endfunction "}}}

" MERGE:
function! sample#inter1#merge(that) abort "{{{
    call a:that._merge_(s:class)
endfunction "}}}

" ISOBJECT:
function! sample#inter1#isobject(that) abort "{{{
    return s:class._isobject_(a:that)
endfunction "}}}
function! sample#inter1#isa(that) abort "{{{
    return s:class._isa_(a:that)
endfunction "}}}

echo 'sample#inter1 is loading'

" TEST:
function! sample#inter1#test(...) abort "{{{
    return 0
endfunction "}}}
