" Class: class#viml#option#multiple
" Author: lymslive
" Description: option with multiple argument
" Create: 2017-02-25
" Modify: 2017-08-05

"LOAD:
if exists('s:load') && !exists('g:DEBUG')
    finish
endif

" CLASS:
let s:class = class#viml#option#pairs#old()
let s:class._name_ = 'class#viml#option#multiple'
let s:class._version_ = 1

" redefien argument and default type
unlet! s:class.Argument
unlet! s:class.Default
let s:class.Argument = []
let s:class.Default = []

function! class#viml#option#multiple#class() abort "{{{
    return s:class
endfunction "}}}

" NEW:
function! class#viml#option#multiple#new(...) abort "{{{
    let l:obj = class#new(s:class, a:000)
    return l:obj
endfunction "}}}

" CTOR: 4 arguments
function! class#viml#option#multiple#ctor(this, ...) abort "{{{
    let l:Suctor = class#Suctor(s:class)
    call l:Suctor(a:this, a:1, a:2, a:3)

    let a:this.Argument = []
    let a:this.Default = []
    if a:0 > 3
        let a:this.HasDefault = v:true
        if type(a:4) == type([])
            call extend(a:this.Default, a:4)
        else
            call add(a:this.Default, a:4)
        endif
    endif
endfunction "}}}

" SetValue: 
function! s:class.SetValue(arg) dict abort "{{{
    let self.Set = v:true
    call add(self.Argument, a:arg)
endfunction "}}}

" ISOBJECT:
function! class#viml#option#multiple#isobject(that) abort "{{{
    return class#isobject(s:class, a:that)
endfunction "}}}

" LOAD:
let s:load = 1
:DLOG 'class#viml#option#multiple is loading ...'
function! class#viml#option#multiple#load(...) abort "{{{
    if a:0 > 0 && !empty(a:1) && exists('s:load')
        unlet s:load
        return 0
    endif
    return s:load
endfunction "}}}

" TEST:
function! class#viml#option#multiple#test(...) abort "{{{
    return 0
endfunction "}}}
