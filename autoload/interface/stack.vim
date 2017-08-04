" Class: interface#stack
" Author: lymslive
" Description: used a stack
" Create: 2017-03-14
" Modify: 2017-08-04

"LOAD:
if exists('s:load') && !exists('g:DEBUG')
    finish
endif

" CLASS:
let s:class = interface#list#old()
let s:class._name_ = 'interface#stack'
let s:class._version_ = 1

function! interface#stack#class() abort "{{{
    return s:class
endfunction "}}}

" NEW:
function! interface#stack#new(...) abort "{{{
    let l:obj = class#new(s:class, a:000)
    return l:obj
endfunction "}}}
" CTOR:
function! interface#stack#ctor(this, ...) abort "{{{
    if a:0 == 0
        let a:this.stack_ = []
    elseif type(a:1) == v:t_list
        let a:this.stack_ = a:1
    else
        : ELOG '[interface#stack#ctor] expect a list variable'
    endif
    let l:Suctor = class#Suctor(s:class)
    call l:Suctor(a:this, a:this.stack_)
endfunction "}}}

" MERGE:
function! interface#stack#merge(that) abort "{{{
    call a:that._merge_(s:class)
endfunction "}}}

" stack: user class must implement, operate which list?
function! s:class.stack() dict abort "{{{
    if has_key(self, 'stack_')
        return self.stack_
    else
        return self.list()
    endif
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
