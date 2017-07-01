" Class: interface#stack
" Author: lymslive
" Description: used a stack
" Create: 2017-03-14
" Modify: 2017-06-30

"LOAD:
if exists('s:load') && !exists('g:DEBUG')
    finish
endif

" CLASS:
" let s:class = class#old()
let s:class = {}
let s:class._name_ = 'interface#stack'
let s:class._version_ = 1

function! interface#stack#class() abort "{{{
    return s:class
endfunction "}}}

" MERGE:
function! interface#stack#merge(that) abort "{{{
    call a:that._merge_(s:class)
endfunction "}}}

" stack: user class must implement, operate which list?
function! s:class.stack() dict abort "{{{
    return []
endfunction "}}}

" push: 
function! s:class.push(item) dict abort "{{{
    let l:stack = self.stack()
    call add(l:stack, a:item)
endfunction "}}}

" pop: 
function! s:class.pop() dict abort "{{{
    let l:stack = self.stack()
    if empty(l:stack)
        return ''
    endif
    return remove(l:stack, -1)
endfunction "}}}

" top: 
function! s:class.top() dict abort "{{{
    let l:stack = self.stack()
    if empty(l:stack)
        return ''
    endif
    return l:stack[-1]
endfunction "}}}

" LOAD:
let s:load = 1
:DLOG '-1 interface#stack is loading ...'
function! interface#stack#load(...) abort "{{{
    if a:0 > 0 && !empty(a:1) && exists('s:load')
        unlet s:load
        return 0
    endif
    return s:load
endfunction "}}}

" TEST:
function! interface#stack#test(...) abort "{{{
    return 0
endfunction "}}}
