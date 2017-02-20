" Class: sample#subsub
" Author: lymslive
" Description: VimL class frame
" Create: 2017-02-20
" Modify: 2017-02-20

" CLASS:
let s:class = sample#sub#old()
call sample#inter3#merge(s:class)
let s:class._name_ = 'sample#subsub'
let s:class._version_ = 1

function! sample#subsub#class() abort "{{{
    return s:class
endfunction "}}}

" NEW:
function! sample#subsub#new(...) abort "{{{
    let l:obj = copy(s:class)
    call l:obj._new_(a:000)
    return l:obj
endfunction "}}}

" CTOR:
function! sample#subsub#ctor(this, argv) abort "{{{
    let l:Suctor = s:class._suctor_()
    call l:Suctor(a:this, a:argv)
endfunction "}}}

" ISOBJECT:
function! sample#subsub#isobject(that) abort "{{{
    return s:class._isobject_(a:that)
endfunction "}}}
function! sample#subsub#isa(that) abort "{{{
    return s:class._isa_(a:that)
endfunction "}}}

echo 'sample#subsub is loading ...'

" TEST:
function! sample#subsub#test(...) abort "{{{
    if a:0 > 1
        let l:jsub = sample#subsub#new(a:1, a:2)
    else
        let l:jsub = sample#subsub#new()
    endif
    echo l:jsub.subProperty l:jsub.baseProperty

    call l:jsub.SubMethod()
    call l:jsub.BaseMethod()
    call l:jsub.InterFuncA1()
    call l:jsub.InterFuncB1()
    call l:jsub.InterFuncA2()
    call l:jsub.InterFuncB2()
    call l:jsub.InterFuncA3()
    call l:jsub.InterFuncB3()

    echo 'jsub sub#isobject? ' . sample#sub#isobject(l:jsub)
    echo 'jsub base#isobject? ' . sample#base#isobject(l:jsub)

    echo 'jsub sub#isa? ' . sample#sub#isa(l:jsub)
    echo 'jsub base#isa? ' . sample#base#isa(l:jsub)
    echo 'jsub inter1#isa? ' . sample#inter1#isa(l:jsub)
    echo 'jsub inter2#isa? ' . sample#inter2#isa(l:jsub)
    echo 'jsub inter3#isa? ' . sample#inter3#isa(l:jsub)
endfunction "}}}
