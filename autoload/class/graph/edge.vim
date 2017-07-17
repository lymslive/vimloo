" Class: class#graph#edge
" Author: lymslive
" Description: edge object of a graph
" Create: 2017-07-12
" Modify: 2017-07-12

"LOAD:
if exists('s:load') && !exists('g:DEBUG')
    finish
endif

" CLASS:
let s:class = class#old()
let s:class._name_ = 'class#graph#edge'
let s:class._version_ = 1

let s:class.from = {}
let s:class.to = {}
let s:class.weight = 1
" more custome data related to this edge
let s:class.data = {}

function! class#graph#edge#class() abort "{{{
    return s:class
endfunction "}}}

" NEW: #new(from, to, [weight, data])
function! class#graph#edge#new(...) abort "{{{
    let l:obj = copy(s:class)
    call l:obj._new_(a:000, 1)
    return l:obj
endfunction "}}}
" CTOR:
function! class#graph#edge#ctor(this, from, to, ...) abort "{{{
    if !class#graph#node#isobject(a:from) || !class#graph#node#isobject(a:to)
        :ELOG 'a graph edge expect to connect two vertice'
        return
    endif

    let a:this.from = a:from
    let a:this.to = a:to

    if a:0 >= 1
        let a:this.weight = a:1
    else
        let a:this.weight = 1
    endif

    if a:0 >= 2
        let a:this.data = a:2
    else
        let a:this.data = {}
    endif
endfunction "}}}

" ISOBJECT:
function! class#graph#edge#isobject(that) abort "{{{
    return s:class._isobject_(a:that)
endfunction "}}}

" AttachData: 
function! s:class.AttachData(data) dict abort "{{{
    let self.data = a:data
    return self
endfunction "}}}
" AppendData: 
function! s:class.AppendData(data, ...) dict abort "{{{
    let l:conflict = get(a:000, 'error')
    call extend(self.data, a:data, l:conflict)
    return self
endfunction "}}}

" LOAD:
let s:load = 1
:DLOG '-1 class#graph#edge is loading ...'
function! class#graph#edge#load(...) abort "{{{
    if a:0 > 0 && !empty(a:1) && exists('s:load')
        unlet s:load
        return 0
    endif
    return s:load
endfunction "}}}

" TEST:
function! class#graph#edge#test(...) abort "{{{
    return 0
endfunction "}}}
