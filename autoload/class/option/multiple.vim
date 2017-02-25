" Class: module#less#multiple
" Author: lymslive
" Description: option with multiple argument
" Create: 2017-02-25
" Modify: 2017-02-25

"LOAD:
if exists('s:load') && !exists('g:DEBUG')
    finish
endif

" CLASS:
let s:class = class#old()
let s:class._name_ = 'module#less#multiple'
let s:class._version_ = 1

" redefien argument and default type
unlet! s:class.Argument
unlet! s:class.Default
let s:class.Argument = []
let s:class.Default = []

function! module#less#multiple#class() abort "{{{
    return s:class
endfunction "}}}

" NEW:
function! module#less#multiple#new(...) abort "{{{
    let l:obj = copy(s:class)
    call l:obj._new_(a:000)
    return l:obj
endfunction "}}}

" CTOR: 4 arguments
function! module#less#multiple#ctor(this, argv) abort "{{{
    let l:Suctor = s:class._suctor_()
    call l:Suctor(a:this, a:argv[0:2])

    let a:this.Argument = []
    let a:this.Default = []
    if len(a:argv) > 3
        let a:this.HasDefault = v:true
        if type(a:argv[3]) == type([])
            call expand(a:this.Default, a:argv[3])
        else
            call add(a:this.Default, a:argv[3])
        endif
    endif
endfunction "}}}

" SetValue: 
function! s:class.SetValue(arg) dict abort "{{{
    let self.Set = v:true
    call add(self.Argument, arg)
endfunction "}}}

" ISOBJECT:
function! module#less#multiple#isobject(that) abort "{{{
    return s:class._isobject_(a:that)
endfunction "}}}

" LOAD:
let s:load = 1
:DLOG 'module#less#multiple is loading ...'
function! module#less#multiple#load(...) abort "{{{
    if a:0 > 0 && !empty(a:1) && exists('s:load')
        unlet s:load
        return 0
    endif
    return s:load
endfunction "}}}

" TEST:
function! module#less#multiple#test(...) abort "{{{
    return 0
endfunction "}}}
