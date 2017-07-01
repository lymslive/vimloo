" Class: class#math#polyline
" Author: lymslive
" Description: a set of point in order, connected successively
" Create: 2017-06-30
" Modify: 2017-06-30

"LOAD:
if exists('s:load') && !exists('g:DEBUG')
    finish
endif

" CLASS:
let s:class = class#old()
let s:class._name_ = 'class#math#polyline'
let s:class._version_ = 1

let s:points = []
" closed polyline means connect the last point to the first
let s:closed = v:false

function! class#math#polyline#class() abort "{{{
    return s:class
endfunction "}}}

" NEW: #new(pt1, pt2, pt3, ...)
function! class#math#polyline#new(...) abort "{{{
    let l:obj = copy(s:class)
    call l:obj._new_(a:000, 1)
    return l:obj
endfunction "}}}
" CTOR:
function! class#math#polyline#ctor(this, ...) abort "{{{
    " let l:Suctor = s:class._suctor_()
    " call l:Suctor(a:this)
    let a:this.points = []

    if a:0 <= 0
        return
    endif

    for l:idx in range(a:0)
        call a:this.AddPoint(a:1)
    endfor
endfunction "}}}

" ISOBJECT:
function! class#math#polyline#isobject(that) abort "{{{
    return s:class._isobject_(a:that)
endfunction "}}}

" AddPoint: 
function! s:class.AddPoint(pt) dict abort "{{{
    if !class#math#point#isobject(a:pt)
        :ELOG 'polyline.AddPoint() expect a point object'
        return self
    endif

    call add(self.points, a:pt)
endfunction "}}}

" SetClose: 
function! s:class.SetClose(bClose) dict abort "{{{
    if empty(a:bClose)
        let self.closed = v:false
    else
        let self.closed = v:true
    endif
    return self
endfunction "}}}

" IsClose: 
function! s:class.IsClose() dict abort "{{{
    return self.closed
endfunction "}}}

" LOAD:
let s:load = 1
:DLOG '-1 class#math#polyline is loading ...'
function! class#math#polyline#load(...) abort "{{{
    if a:0 > 0 && !empty(a:1) && exists('s:load')
        unlet s:load
        return 0
    endif
    return s:load
endfunction "}}}

" TEST:
function! class#math#polyline#test(...) abort "{{{
    return 0
endfunction "}}}
