" Class: sample#sub
" Author: lymslive
" Description: VimL class frame
" Create: 2017-02-20
" Modify: 2017-02-20

" CLASS:
let s:class = class#old('sample#base', 'sample#inter1', 'sample#inter2')
let s:class._name_ = 'sample#sub'
let s:class._version_ = 1

let s:class.subProperty = 'subProperty'

function! sample#sub#class() abort "{{{
    return s:class
endfunction "}}}

" NEW:
function! sample#sub#new(...) abort "{{{
    let l:obj = copy(s:class)
    call l:obj._new_(a:000)
    return l:obj
endfunction "}}}

" CTOR:
function! sample#sub#ctor(this, argv) abort "{{{
    if len(a:argv) > 0
        let self.subProperty = a:1
    endif
    if len(a:argv) > 1
        let l:Suctor = s:class._suctor_()
        call l:Suctor(a:this, [a:2])
    endif
endfunction "}}}

" SubMethod: 
function! s:class.SubMethod() dict abort "{{{
    echo 'calling SubMethod()'
endfunction "}}}

" ISOBJECT:
function! sample#sub#isobject(that) abort "{{{
    return s:class._isobject_(a:that)
endfunction "}}}
function! sample#sub#isa(that) abort "{{{
    return s:class._isa_(a:that)
endfunction "}}}

" TEST:
function! sample#sub#test(...) abort "{{{
    let l:jsub = sample#sub#new()
    echo l:jsub.subProperty l:jsub.baseProperty

    call l:jsub.SubMethod()
    call l:jsub.BaseMethod()
    call l:jsub.InterFuncA1()
    call l:jsub.InterFuncB1()
    call l:jsub.InterFuncA2()
    call l:jsub.InterFuncB2()

    echo 'jsub sub#isobject? ' . sample#sub#isobject(l:jsub)
    echo 'jsub base#isobject? ' . sample#base#isobject(l:jsub)

    echo 'jsub sub#isa? ' . sample#sub#isa(l:jsub)
    echo 'jsub base#isa? ' . sample#base#isa(l:jsub)
    echo 'jsub inter1#isa? ' . sample#inter1#isa(l:jsub)
    echo 'jsub inter2#isa? ' . sample#inter2#isa(l:jsub)
    return 0
endfunction "}}}
