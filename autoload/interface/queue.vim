" Class: interface#queue
" Author: lymslive
" Description: VimL class frame
" Create: 2017-03-14
" Modify: 2017-03-14

"LOAD:
if exists('s:load') && !exists('g:DEBUG')
    finish
endif

" CLASS:
" let s:class = class#old()
let s:class = {}
let s:class._name_ = 'interface#queue'
let s:class._version_ = 1

function! interface#queue#class() abort "{{{
    return s:class
endfunction "}}}

" MERGE:
function! interface#queue#merge(that) abort "{{{
    call a:that._merge_(s:class)
endfunction "}}}

" list: user class must implement, operate which list?
function! s:class.list() dict abort "{{{
    return []
endfunction "}}}

" push: 
function! s:class.push(item) dict abort "{{{
    let l:list = self.list()
    call add(l:list, a:item)
endfunction "}}}

" shift: 
function! s:class.shift() dict abort "{{{
    let l:list = self.list()
    if empty(l:list)
        return ''
    endif
    return remove(l:list, 0)
endfunction "}}}

" front: 
function! s:class.front() dict abort "{{{
    let l:list = self.list()
    if empty(l:list)
        return ''
    endif
    return l:list[0]
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
