" Class: class#more#list
" Author: lymslive
" Description: VimL class frame
" Create: 2017-08-02
" Modify: 2017-08-07

"LOAD:
if exists('s:load') && !exists('g:DEBUG')
    finish
endif

" CLASS:
let s:class = class#old()
let s:class._name_ = 'class#more#list'
let s:class._version_ = 1

function! class#more#list#class() abort "{{{
    return s:class
endfunction "}}}

" NEW:
function! class#more#list#new(...) abort "{{{
    let l:obj = class#new(s:class, a:000)
    return l:obj
endfunction "}}}
" CTOR:
function! class#more#list#ctor(this, ...) abort "{{{
    if a:0 == 0
        let a:this.list_ = []
    elseif type(a:1) == v:t_list
        let a:this.list_ = a:1
    else
        : ELOG '[class#more#list#ctor] expect a list variable'
    endif
endfunction "}}}

" OLD:
function! class#more#list#old() abort "{{{
    let l:class = class#old(s:class)
    return l:class
endfunction "}}}

" list: 
function! s:class.list() dict abort "{{{
    if has_key(self, 'list_')
        return self.list_
    else
        : ELOG '[class#more#list] ' . 'not implement list()'
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
:DLOG '-1 class#more#list is loading ...'
function! class#more#list#load(...) abort "{{{
    if a:0 > 0 && !empty(a:1) && exists('s:load')
        unlet s:load
        return 0
    endif
    return s:load
endfunction "}}}

" TEST:
function! class#more#list#test(...) abort "{{{
    return 0
endfunction "}}}
