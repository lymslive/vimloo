" HEADER: -H
" File: tempclass.vim
" Author: lymslive
" Description: template sample class frame
" Create: 2017-02-10
" Modify: 2017-02-10

" BASIC:
let s:class = class#old()
let s:class._name_ = 'tempclass'
let s:class._version_ = 1

function! tempclass#class() abort "{{{
    return s:class
endfunction "}}}

" CTOR: -c
function! tempclass#ctor(this, argc, argv) abort "{{{
endfunction "}}}

" DECTOR: -D
function! tempclass#dector() abort "{{{
endfunction "}}}

" NEW: -N
function! tempclass#new(...) abort "{{{
    let l:obj = copy(s:class)
    call l:obj._new_(a:000)
    return l:obj
endfunction "}}}

" OLD: -O
function! tempclass#old() abort "{{{
    let l:class = copy(s:class)
    call l:class._old_()
    return l:class
endfunction "}}}

" INSTANCE: -i
let s:instance = {}
function! tempclass#instance() abort "{{{
    if empty(s:instance)
        let s:instance = class#new('tempclass')
    endif
    return s:instance
endfunction "}}}

" CONVERSION: -X
function! s:class.string() dict abort "{{{
    return self._name_
endfunction "}}}
function! s:class.number() dict abort "{{{
    return self._version_
endfunction "}}}

" LOAD: -l
function! tempclass#load() abort "{{{
    return 1
endfunction "}}}

" TEST: -t
function! tempclass#test() abort "{{{
    return 1
endfunction "}}}
