" Class: sample#inter2
" Author: lymslive
" Description: VimL class frame
" Create: 2017-02-20
" Modify: 2017-02-20

" CLASS:
let s:class = class#old()
let s:class._name_ = 'sample#inter3'
let s:class._version_ = 1

function! sample#inter3#class() abort "{{{
    return s:class
endfunction "}}}

" InterFuncA3: 
function! s:class.InterFuncA3() dict abort "{{{
    echo 'calling InterFuncA3 of sample#inter3'
endfunction "}}}
" InterFuncB3: 
function! s:class.InterFuncB3() dict abort "{{{
    echo 'calling InterFuncB3 of sample#inter3'
endfunction "}}}

" MERGE:
function! sample#inter3#merge(that) abort "{{{
    call a:that._merge_(s:class)
endfunction "}}}

" ISOBJECT:
function! sample#inter3#isobject(that) abort "{{{
    return s:class._isobject_(a:that)
endfunction "}}}
function! sample#inter3#isa(that) abort "{{{
    return s:class._isa_(a:that)
endfunction "}}}

echo 'sample#inter3 is loading'

" TEST:
function! sample#inter3#test(...) abort "{{{
    return 0
endfunction "}}}
