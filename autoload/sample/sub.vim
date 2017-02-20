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
        let a:this.subProperty = a:argv[0]
    endif
    if len(a:argv) > 1
        let l:Suctor = s:class._suctor_()
        call l:Suctor(a:this, [a:argv[1]])
    endif
endfunction "}}}

" COPY:
function! sample#sub#copy(that, ...) abort "{{{
    let l:obj = copy(s:class)
    call l:obj._copy_(a:that)
    if a:0 > 0
        let l:obj.subProperty = a:1
    endif
    return l:obj
endfunction "}}}

" OLD:
function! sample#sub#old() abort "{{{
    let l:class = copy(s:class)
    call l:class._old_()
    return l:class
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
    if a:0 > 1
        let l:jsub = sample#sub#new(a:1, a:2)
    else
        let l:jsub = sample#sub#new()
    endif
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

    let l:jbase = sample#base#new('base')
    let l:jcsub = sample#sub#copy(l:jbase, 'sub')
    echo l:jcsub._name_ l:jcsub._super_
    echo l:jcsub.baseProperty l:jcsub.subProperty
    return 0
endfunction "}}}
