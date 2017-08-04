" Class: class#fantasy#game
" Author: lymslive
" Description: Game in VimL
" Create: 2017-07-12
" Modify: 2017-08-04

"LOAD:
if exists('s:load') && !exists('g:DEBUG')
    finish
endif

" CLASS:
let s:class = class#old()
let s:class._name_ = 'class#fantasy#game'
let s:class._version_ = 1

function! class#fantasy#game#class() abort "{{{
    return s:class
endfunction "}}}

" NEW:
function! class#fantasy#game#new(...) abort "{{{
    let l:obj = class#new(s:class, a:000)
    return l:obj
endfunction "}}}
" CTOR:
function! class#fantasy#game#ctor(this, ...) abort "{{{
    " let l:Suctor = class#Suctor(s:class)
    " call l:Suctor(a:this)
endfunction "}}}

" OLD:
function! class#fantasy#game#old() abort "{{{
    let l:class = class#old(s:class)
    return l:class
endfunction "}}}

" ISOBJECT:
function! class#fantasy#game#isobject(that) abort "{{{
    return class#isobject(s:class, a:that)
endfunction "}}}

" LOAD:
let s:load = 1
:DLOG '-1 class#fantasy#game is loading ...'
function! class#fantasy#game#load(...) abort "{{{
    if a:0 > 0 && !empty(a:1) && exists('s:load')
        unlet s:load
        return 0
    endif
    return s:load
endfunction "}}}

" TEST:
function! class#fantasy#game#test(...) abort "{{{
    return 0
endfunction "}}}
