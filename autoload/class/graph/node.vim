" Class: class#graph#node
" Author: lymslive
" Description: VimL class frame
" Create: 2017-07-12
" Modify: 2017-07-12

"LOAD:
if exists('s:load') && !exists('g:DEBUG')
    finish
endif

" CLASS:
let s:class = class#old()
let s:class._name_ = 'class#graph#node'
let s:class._version_ = 1

" identifier of a vertex node
let s:class.id = 0
" custome data related to this node
let s:class.data = {}
" edges to other vertext, a list of other vertext node
let s:class.edge = []

function! class#graph#node#class() abort "{{{
    return s:class
endfunction "}}}

" NEW:
function! class#graph#node#new(...) abort "{{{
    let l:obj = copy(s:class)
    call l:obj._new_(a:000, 1)
    return l:obj
endfunction "}}}
" CTOR:
function! class#graph#node#ctor(this, ...) abort "{{{
    if a:0 >= 1
        let a:this.id = a:1
    endif
    if a:0 >= 2
        let a:this.data = a:2
    else
        let a:this.data = {}
    endif
    if a:0 >= 3
        let a:this.edge = a:3
    else
        let a:this.edge = []
    endif
endfunction "}}}

" ISOBJECT:
function! class#graph#node#isobject(that) abort "{{{
    return s:class._isobject_(a:that)
endfunction "}}}

" AddEdge: add a edge object in my list
" the edge should be from this vertex
" a:1, check existed edge
let s:SAFE_CHECK = 1
function! s:class.AddEdge(jEdge, ...) dict abort "{{{
    if !class#graph#edge#isobject(a:jEdge)
        :ELOG 'expect a graph edge object'
        return v:none
    endif

    if a:0 > 0 && !empty(a:1)
        for l:edge in self.edge
            if l:edge is a:jEdge
                :WLOG 'the edge already in list'
                return self
            endif
        endfor
    endif

    if a:jEdge.from isnot self
        :ELOG 'the edge is not from this vertex'
        return v:none
    endif

    call add(self.edge, a:jEdge)
    return self
endfunction "}}}

" Connect: connect to another vertex, create a edge object
function! s:class.Connect(vertex, ...) dict abort "{{{
    if !class#graph#node#isobject(a:vertex)
        :ELOG 'expect to connect to another vertex node'
        return v:none
    endif

    if a:vertex is self
        :WLOG 'a graph vertex cannot connect to itself'
        return self
    endif

    " default edge weigth is 1
    let l:weight = get(a:000, 0, 1)
    let l:jEdge = class#graph#edge#new(self, a:vertex, l:weight)
    return self.AddEdge(l:jEdge, s:SAFE_CHECK)
endfunction "}}}

" RemoveEdge: 
function! s:class.RemoveEdge(jEdge) dict abort "{{{
    for l:index in range(len(self.edge))
        let l:edge = self.edge[l:index]
        if l:edge is a:jEdge
            call remove(self.edge, l:index)
            return self
        endif
    endfor
    :WLOG 'this edge has no relation with this vertex, something maybe error'
    return self
endfunction "}}}

" Disconnect: 
function! s:class.Disconnect(vertex) dict abort "{{{
    for l:index in range(len(self.edge))
        let l:edge = self.edge[l:index]
        if l:edge.to is a:vertex
            call remove(self.edge, l:index)
            return self
        endif
    endfor
    :WLOG 'this vertex has no edge to that vertex, something maybe error'
    return self
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
