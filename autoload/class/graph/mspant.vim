" Class: class#graph#mspant
" Author: lymslive
" Description: min span tree
" Create: 2017-07-31
" Modify: 2017-08-02

"LOAD:
if exists('s:load') && !exists('g:DEBUG')
    finish
endif

" CLASS:
let s:class = class#old()
let s:class._name_ = 'class#graph#mspant'
let s:class._version_ = 1

" refer to the origin graph
let s:class.graph = {}
" the collection of edge in the span tree
let s:class.tree = []

function! class#graph#mspant#class() abort "{{{
    return s:class
endfunction "}}}

" NEW:
function! class#graph#mspant#new(...) abort "{{{
    if a:0 < 1 || !class#graph#isobject(a:1)
        : ELOG '[#graph#mspant] expect a graph object'
        return v:none
    endif
    let l:obj = copy(s:class)
    call l:obj._new_(a:000, 1)
    return l:obj
endfunction "}}}
" CTOR:
function! class#graph#mspant#ctor(this, graph) abort "{{{
    " let l:Suctor = s:class._suctor_()
    " call l:Suctor(a:this)
    let a:this.graph = a:graph
    let a:this.tree = []
endfunction "}}}

" ISOBJECT:
function! class#graph#mspant#isobject(that) abort "{{{
    return s:class._isobject_(a:that)
endfunction "}}}

" GetTree: 
function! s:class.GetTree() dict abort "{{{
    return self.tree
endfunction "}}}

" Kruskal: 
function! s:class.Kruskal() dict abort "{{{
    let l:set = class#set#disjoint#new()
    for l:vertex in self.graph.vertex
        call l:set.MakeSet(l:vertex.id)
    endfor

    if !empty(self.tree)
        let self.tree = []
    endif

    let l:lsEdge = self.graph.EdgeList(1)
    for l:edge in l:lsEdge
        if l:set.Find(l:edge.from.id) != l:set.Find(l:edge.to.id)
            call add(self.tree, l:edge)
            call l:set.Union(l:edge.from.id, l:edge.to.id)
        endif
    endfor

    call l:set.Free()
    return self.tree
endfunction "}}}

" disp: 
function! s:class.disp() dict abort "{{{
    echo 'Min Span Tree Edge: *' . len(self.tree)
    let l:iSum = 0
    for l:edge in self.tree
        echo printf('  [%s-->%s] = %d', l:edge.from.id, l:edge.to.id, l:edge.weight)
        let l:iSum += l:edge.weight
    endfor
    echo '  Total Weight: ' . l:iSum
endfunction "}}}

" LOAD:
let s:load = 1
:DLOG '-1 class#graph#mspant is loading ...'
function! class#graph#mspant#load(...) abort "{{{
    if a:0 > 0 && !empty(a:1) && exists('s:load')
        unlet s:load
        return 0
    endif
    return s:load
endfunction "}}}

" TEST:
function! class#graph#mspant#test(...) abort "{{{
    return 0
endfunction "}}}
