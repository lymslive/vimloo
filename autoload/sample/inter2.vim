" Class: sample#inter2
" Author: lymslive
" Description: VimL class frame
" Create: 2017-02-20
" Modify: 2017-02-20

" CLASS:
let s:class = class#old()
let s:class._name_ = 'sample#inter2'
let s:class._version_ = 1

function! sample#inter2#class() abort "{{{
    return s:class
endfunction "}}}

" InterFuncA2: 
function! s:class.InterFuncA2() dict abort "{{{
    echo 'calling InterFuncA2 of sample#inter2'
endfunction "}}}
" InterFuncB2: 
function! s:class.InterFuncB2() dict abort "{{{
    echo 'calling InterFuncB2 of sample#inter2'
endfunction "}}}

" MERGE:
function! sample#inter2#merge(that) abort "{{{
    call a:that._merge_(s:class)
endfunction "}}}

" ISOBJECT:
function! sample#inter2#isobject(that) abort "{{{
    return s:class._isobject_(a:that)
endfunction "}}}
function! sample#inter2#isa(that) abort "{{{
    return s:class._isa_(a:that)
endfunction "}}}

echo 'sample#inter2 is loading'

" TEST:
function! sample#inter2#test(...) abort "{{{
    return 0
endfunction "}}}
