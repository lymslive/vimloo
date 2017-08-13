" Class: class#buffer#based
" Author: lymslive
" Description: VimL class frame
" Create: 2017-08-13
" Modify: 2017-08-13

"LOAD:
if exists('s:load') && !exists('g:DEBUG')
    finish
endif

" CLASS:
let s:class = class#old()
let s:class._name_ = 'class#buffer#based'
let s:class._version_ = 1

" the logical owner object
let s:class.owner = class#new()
let s:class.bufnr = 0

function! class#buffer#based#class() abort "{{{
    return s:class
endfunction "}}}

" NEW:
function! class#buffer#based#new(...) abort "{{{
    let l:obj = class#new(s:class, a:000)
    return l:obj
endfunction "}}}
" CTOR:
function! class#buffer#based#ctor(this, ...) abort "{{{
    let a:this.bufnr = bufnr('%')
endfunction "}}}

" OLD:
function! class#buffer#based#old() abort "{{{
    let l:class = class#old(s:class)
    return l:class
endfunction "}}}

" ISOBJECT:
function! class#buffer#based#isobject(that) abort "{{{
    return class#isobject(s:class, a:that)
endfunction "}}}

" SetOwner: 
function! s:class.SetOwner(obj) dict abort "{{{
    let self.owner = a:obj
endfunction "}}}

" RegBufvar: 
function! s:class.RegBufvar(bufvar) dict abort "{{{
    if has_key(b:, a:bufvar) && b:[a:bufvar] isnot self
        : WLOG 'overide already existed bufvar: ' . a:bufvar
    endif
    let b:[a:bufvar] = self
endfunction "}}}
" RegTabvar: 
function! s:class.RegTabvar(tabvar) dict abort "{{{
    if has_key(t:, a:tabvar) && t:[a:tabvar] isnot self
        : WLOG 'overide already existed bufvar: ' . t:tabvar
    endif
    let t:[a:tabvar] = self
endfunction "}}}

" Focus: 
function! s:class.Focus(...) dict abort "{{{
    if bufnr('%') == self.bufnr
        return self
    endif

    " load buffer in current window
    if a:0 == 0 || empty(a:1)
        : execute 'buffer .' self.bufnr
        return self
    endif

    " current tabpage, other window
    let l:iWindow = bufwinnr(self.bufnr)
    if l:iWindow != -1
        : execute l:iWindow . 'wincmd w'
        return self
    endif

    " try other tabpage
    if a:1 =~? 't'
        let l:FWindow = class#less#window#export()
        let l:target = l:FWindow.FindBufwinnr(self.bufnr)
        if !empty(l:target) && type(l:target) == v:t_list
            let l:tab = l:target[0]
            let l:win = l:target[1]
            : execute l:tab . 'tabnext'
            : execute l:win . 'wincmd w'
            return self
        endif
    endif

    " back to load in origin window
    : execute 'buffer .' self.bufnr
    return self
endfunction "}}}

" LOAD:
let s:load = 1
function! class#buffer#based#load(...) abort "{{{
    if a:0 > 0 && !empty(a:1)
        unlet! s:load
    endif
endfunction "}}}

" TEST:
function! class#buffer#based#test(...) abort "{{{
    let l:obj = class#buffer#based#new()
    call class#echo(l:obj)
endfunction "}}}
