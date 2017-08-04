" Class: interface#queue
" Author: lymslive
" Description: VimL class frame
" Create: 2017-03-14
" Modify: 2017-08-04

"LOAD:
if exists('s:load') && !exists('g:DEBUG')
    finish
endif

" CLASS:
let s:class = interface#list#old()
let s:class._name_ = 'interface#queue'
let s:class._version_ = 1

function! interface#queue#class() abort "{{{
    return s:class
endfunction "}}}

" NEW:
function! interface#queue#new(...) abort "{{{
    let l:obj = class#new(s:class, a:000)
    return l:obj
endfunction "}}}
" CTOR:
function! interface#queue#ctor(this, ...) abort "{{{
    if a:0 == 0
        let a:this.queue_ = []
    elseif type(a:1) == v:t_list
        let a:this.queue_ = a:1
    else
        : ELOG '[interface#queue#ctor] expect a list variable'
    endif
    let l:Suctor = class#Suctor(s:class)
    call l:Suctor(a:this, a:this.heap_)
endfunction "}}}

" MERGE:
function! interface#queue#merge(that) abort "{{{
    call a:that._merge_(s:class)
endfunction "}}}

" queue: user class must implement, operate which list?
function! s:class.queue() dict abort "{{{
    if has_key(self, 'queue_')
        return self.queue_
    else
        return self.list()
    endif
endfunction "}}}

" push: 
function! s:class.push(item) dict abort "{{{
    let l:queue = self.queue()
    call add(l:queue, a:item)
endfunction "}}}

" shift: 
function! s:class.shift() dict abort "{{{
    let l:queue = self.queue()
    if empty(l:queue)
        return ''
    endif
    return remove(l:queue, 0)
endfunction "}}}

" front: 
function! s:class.front() dict abort "{{{
    let l:queue = self.queue()
    if empty(l:queue)
        return ''
    endif
    return l:queue[0]
endfunction "}}}

" LOAD:
let s:load = 1
:DLOG '-1 interface#queue is loading ...'
function! interface#queue#load(...) abort "{{{
    if a:0 > 0 && !empty(a:1) && exists('s:load')
        unlet s:load
        return 0
    endif
    return s:load
endfunction "}}}

" TEST:
function! interface#queue#test(...) abort "{{{
    return 0
endfunction "}}}
