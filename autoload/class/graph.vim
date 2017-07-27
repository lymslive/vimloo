" Class: class#graph
" Author: lymslive
" Description: Graph data struct in VimL
" Create: 2017-07-12
" Modify: 2017-07-27

"LOAD:
if exists('s:load') && !exists('g:DEBUG')
    finish
endif

" CLASS:
let s:class = class#old()
let s:class._name_ = 'class#graph'
let s:class._version_ = 1

" a graph is mainly a list of vertex node
" the edge information is embeded in vertex node
let s:class.vertex = []

let s:class._autoid = 0

function! class#graph#class() abort "{{{
    return s:class
endfunction "}}}

" NEW:
function! class#graph#new(...) abort "{{{
    let l:obj = copy(s:class)
    call l:obj._new_(a:000, 1)
    return l:obj
endfunction "}}}
" CTOR:
function! class#graph#ctor(this, ...) abort "{{{
    " let l:Suctor = s:class._suctor_()
    " call l:Suctor(a:this)
endfunction "}}}

" ISOBJECT:
function! class#graph#isobject(that) abort "{{{
    return s:class._isobject_(a:that)
endfunction "}}}

" AddVertex: 
" a:1, check existed vertex, default not check
" a:dVertex.id can auto-increace, or explict given by user(guard no repeat)
function! s:class.AddVertex(dVertex, ...) dict abort "{{{
    if a:0 > 0 && !empty(a:1)
        for l:vertex in self.vertex
            if l:vertex is a:dVertex
                :WLOG 'the vertex node already in list'
                return self
            endif
        endfor
    endif

    if a:dVertex.id == 0
        let self._autoid += 1
        let a:dVertex.id = self._autoid
    else
        let self._autoid = a:dVertex.id
    endif

    call add(self.vertex, a:dVertex)
    return self
endfunction "}}}

" RemoveVertex: 
function! s:class.RemoveVertex(dVertex) dict abort "{{{
    for l:index in range(len(self.vertex))
        let l:vertex = self.vertex[l:index]
        if l:vertex is a:dVertex
            call remove(self.vertex, l:index)
            return self
        endif
    endfor
    :WLOG 'the vertex isnot in graph, something wrong?'
    return self
endfunction "}}}

" GetVertexByID: 
function! s:class.GetVertexByID(id) dict abort "{{{
    for l:vertex in self.vertex
        if l:vertex.id == a:id
            return l:vertex
        endif
    endfor
    return {}
endfunction "}}}

" RemoveVertexByID: 
function! s:class.RemoveVertexByID(id) dict abort "{{{
    for l:index in range(len(self.vertex))
        let l:vertex = self.vertex[l:index]
        if l:vertex.id == id
            call remove(self.vertex, l:index)
            return self
        endif
    endfor
    :WLOG 'the vertex isnot in graph, something wrong?'
    return self
endfunction "}}}

" EdgeList: 
function! s:class.EdgeList() dict abort "{{{
    let l:list = []
    for l:vertex in self.vertex
        if !empty(l:vertex.edge)
            call extend(l:list, l:vertex.edge)
        endif
    endfor
    return l:list
endfunction "}}}

" EdgeIterator: 
" call Next() in loop, should not remove/add vertex/edge of graph
function! s:class.EdgeIterator() dict abort "{{{
    let l:it = class#graph#edgeit#new(self)
    return l:it
endfunction "}}}

" string: convert to description text
function! s:class.string() dict abort "{{{
    let l:head = 'Graph: ' . len(self.vertex) . "*Vertex"
    let l:lsText = [l:head]

    for l:vertex in self.vertex
        let l:iEdgeCnt = len(l:vertex.edge)
        let l:sVertex = printf("Vertext: id=%d, %d*Edge\n", l:vertex.id, l:iEdgeCnt)
        for l:edge in l:vertex.edge
            let l:sEdge = printf("  Edge to V[%d]\n", l:edge.to.id)
            let l:sVertex .= l:sEdge
        endfor
        call add(l:lsText, l:sVertex)
    endfor

    return join(l:lsText, "\n")
endfunction "}}}

" disp: 
function! s:class.disp() dict abort "{{{
    let l:text = self.string
    echo l:text
endfunction "}}}

" VertexFieldAdd: 
" add a key to each vertex node, silently overide existed key
" a:key must be string, that can be a key
" a:value init is copied into each node
function! s:class.VertexFieldAdd(key, value) dict abort "{{{
    for l:vertex in self.vertex
        let l:vertex[a:key] = copy(a:value)
    endfor
    return self
endfunction "}}}

" VertexFieldRmv: 
function! s:class.VertexFieldRmv(key) dict abort "{{{
    for l:vertex in self.vertex
        unlet! l:vertex[a:key]
    endfor
    return self
endfunction "}}}

" LOAD:
let s:load = 1
:DLOG '-1 class#graph is loading ...'
function! class#graph#load(...) abort "{{{
    if a:0 > 0 && !empty(a:1) && exists('s:load')
        unlet s:load
        return 0
    endif
    return s:load
endfunction "}}}

" TEST:
function! class#graph#test(...) abort "{{{
    return 0
endfunction "}}}
