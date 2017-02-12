" Class: class#option#single
" Author: lymslive
" Description: option without argument
" Create: 2017-02-12
" Modify: 2017-02-12

" BASIC:
let s:class = class#option#base#old()
let s:class._name_ = 'class#option#single'
let s:class._version_ = 1

" dose this option is set?
let s:class.Set = v:false

function! class#option#single#class() abort "{{{
    return s:class
endfunction "}}}

" CTOR:
function! class#option#single#ctor(this, argv) abort "{{{
    let l:Suctor = a:this._suctor_()
    call l:Suctor(a:this, a:argv)
endfunction "}}}

" NEW:
function! class#option#single#new(...) abort "{{{
    let l:obj = copy(s:class)
    call l:obj._new_(a:000)
    return l:obj
endfunction "}}}

" OLD:
function! class#option#string#old() abort "{{{
    let l:class = copy(s:class)
    call l:class._old_()
    return l:class
endfunction "}}}

" Has: 
function! s:class.Has() dict abort "{{{
    return self.Set
endfunction "}}}

" Value: this type option is just boolean, set or unset
function! s:class.Value() dict abort "{{{
    return self.Has()
endfunction "}}}

" LOAD:
function! class#option#single#load() abort "{{{
    return 1
endfunction "}}}

" TEST:
function! class#option#single#test() abort "{{{
    return 1
endfunction "}}}
