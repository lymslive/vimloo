" Class: class#graph#edgeit
" Author: lymslive
" Description: iterator of graph edge
" Create: 2017-07-12
" Modify: 2017-07-12

"LOAD:
if exists('s:load') && !exists('g:DEBUG')
    finish
endif

" CLASS:
let s:class = class#old()
let s:class._name_ = 'class#graph#edgeit'
let s:class._version_ = 1

" belong to which graph
let s:class.graph = {}

" current index of vertex and edge
let s:class.iv = 0
let s:class.ie = 0

function! class#graph#edgeit#class() abort "{{{
    return s:class
endfunction "}}}

" NEW:
function! class#graph#edgeit#new(...) abort "{{{
    let l:obj = copy(s:class)
    call l:obj._new_(a:000, 1)
    return l:obj
endfunction "}}}
" CTOR:
function! class#graph#edgeit#ctor(this, graph) abort "{{{
    if !class#graph#isobject(a:graph)
        :ELOG 'edgeit expect a owner graph object'
        return v:none
    endif

    let a:this.graph = a:graph
    let a:this.iv = 0
    let a:this.ie = 0
endfunction "}}}

" ISOBJECT:
function! class#graph#edgeit#isobject(that) abort "{{{
    return s:class._isobject_(a:that)
endfunction "}}}

" End: check if the iterator ends, return v:true or v:false
function! s:class.End() dict abort "{{{
    if self.iv >= len(self.graph.vertex)
        return v:true
    elseif self.ie >= len(self.graph.vertex[iv].edge)
        return v:true
    else
        return v:false
    endif
endfunction "}}}

" Next: return the current edge, and step the cursor to next
function! s:class.Next() dict abort "{{{
    if self.End()
        return {}
    endif

    let l:jEdge = self.graph.vertex[self.iv].edge[self.ie]

    let self.ie += 1
    if self.ie >= len(self.graph.vertex[iv].edge)
        let self.iv += 1
        let self.ie = 0
    endif

    return l:jEdge
endfunction "}}}

" LOAD:
let s:load = 1
:DLOG '-1 class#graph#edgeit is loading ...'
function! class#graph#edgeit#load(...) abort "{{{
    if a:0 > 0 && !empty(a:1) && exists('s:load')
        unlet s:load
        return 0
    endif
    return s:load
endfunction "}}}

" TEST:
function! class#graph#edgeit#test(...) abort "{{{
    return 0
endfunction "}}}
