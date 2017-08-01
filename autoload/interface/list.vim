" Class: interface#list
" Author: lymslive
" Description: VimL class frame
" Create: 2017-08-02
" Modify: 2017-08-02

"LOAD:
if exists('s:load') && !exists('g:DEBUG')
    finish
endif

" CLASS:
let s:class = class#old()
let s:class._name_ = 'interface#list'
let s:class._version_ = 1

function! interface#list#class() abort "{{{
    return s:class
endfunction "}}}

" NEW:
function! interface#list#new(...) abort "{{{
    let l:obj = copy(s:class)
    call l:obj._new_(a:000, 1)
    return l:obj
endfunction "}}}
" CTOR:
function! interface#list#ctor(this, ...) abort "{{{
    if a:0 == 0
        let a:this.list_ = []
    elseif type(a:1) == v:t_list
        let a:this.list_ = a:1
    else
        : ELOG '[interface#list#ctor] expect a list variable'
    endif
endfunction "}}}

" OLD:
function! interface#list#old() abort "{{{
    let l:class = copy(s:class)
    call l:class._old_()
    return l:class
endfunction "}}}

" MERGE:
function! interface#list#merge(that) abort "{{{
    call a:that._merge_(s:class)
endfunction "}}}

" list: 
function! s:class.list() dict abort "{{{
    if has_key(self, 'list_')
        return self.list_
    else
        : ELOG '[interface#list] ' . 'not implement list()'
        return []
    endif
endfunction "}}}

" size: 
function! s:class.size() dict abort "{{{
    return len(self.list())
endfunction "}}}
" empty: 
function! s:class.empty() dict abort "{{{
    return empty(self.list())
endfunction "}}}

" string: 
function! s:class.string() dict abort "{{{
    return string(self.list())
endfunction "}}}
" disp: 
function! s:class.disp() dict abort "{{{
    echo self.string()
endfunction "}}}

" LOAD:
let s:load = 1
:DLOG '-1 interface#list is loading ...'
function! interface#list#load(...) abort "{{{
    if a:0 > 0 && !empty(a:1) && exists('s:load')
        unlet s:load
        return 0
    endif
    return s:load
endfunction "}}}

" TEST:
function! interface#list#test(...) abort "{{{
    return 0
endfunction "}}}
