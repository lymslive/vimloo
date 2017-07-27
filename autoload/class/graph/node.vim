" Class: class#graph#node
" Author: lymslive
" Description: the vertex node of a graph
" Create: 2017-07-12
" Modify: 2017-07-27

"LOAD:
if exists('s:load') && !exists('g:DEBUG')
    finish
endif

" CLASS:
" used as inner struct of graph, not based on class but bare dict
let s:class = {}
" identifier of a vertex node
let s:class.id = 0
" edges to other vertex, a list of other vertext node
let s:class.edge = []

function! class#graph#node#class() abort "{{{
    return s:class
endfunction "}}}

" NEW:
function! class#graph#node#new(...) abort "{{{
    let l:obj = copy(s:class)
    if a:0 >= 1
        let l:obj.id = a:1
    endif
    let l:obj.edge = []
    return l:obj
endfunction "}}}

" AddEdge: add a edge object in my list
" the edge should be from this vertex
" a:1, check existed edge if not empty
function! s:class.AddEdge(dEdge, ...) dict abort "{{{
    if a:0 > 0 && !empty(a:1)
        for l:edge in self.edge
            if l:edge is a:dEdge
                :WLOG 'the edge already in list'
                return self
            endif
        endfor
    endif

    if a:dEdge.from isnot self
        :ELOG 'the edge is not from this vertex'
        return v:none
    endif

    call add(self.edge, a:dEdge)
    return self
endfunction "}}}

" Connect: connect to another vertex, create a edge object
function! s:class.Connect(dVertex, ...) dict abort "{{{
    if a:dVertex is self
        :WLOG 'a graph vertex cannot connect to itself'
        return self
    endif

    " default edge weigth is 1
    let l:iWeight = get(a:000, 0, 1)
    let l:dEdge = class#graph#edge#new(self, a:dVertex, l:iWeight)
    return self.AddEdge(l:dEdge)
endfunction "}}}

" RemoveEdge: 
function! s:class.RemoveEdge(dEdge) dict abort "{{{
    for l:index in range(len(self.edge))
        let l:edge = self.edge[l:index]
        if l:edge is a:dEdge
            call remove(self.edge, l:index)
            return self
        endif
    endfor
    :WLOG 'this edge has no relation with this vertex, something maybe error'
    return self
endfunction "}}}

" Disconnect: 
function! s:class.Disconnect(dVertex) dict abort "{{{
    for l:index in range(len(self.edge))
        let l:edge = self.edge[l:index]
        if l:edge.to is a:dVertex
            call remove(self.edge, l:index)
            return self
        endif
    endfor
    :WLOG 'this vertex has no edge to that vertex, something maybe error'
    return self
endfunction "}}}

" LOAD:
let s:load = 1
:DLOG '-1 class#graph#node is loading ...'
function! class#graph#node#load(...) abort "{{{
    if a:0 > 0 && !empty(a:1) && exists('s:load')
        unlet s:load
        return 0
    endif
    return s:load
endfunction "}}}

" TEST:
function! class#graph#node#test(...) abort "{{{
    return 0
endfunction "}}}
