" Class: class#graph
" Author: lymslive
" Description: Graph data struct in VimL
" Create: 2017-07-12
" Modify: 2017-08-01

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

" assign each vertex node a id
let s:class.autoid_ = 0
let s:class.hashid_ = {}

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
    let a:this.vertex = []
    let a:this.autoid_ = 0
    let a:this.hashid_ = {}
endfunction "}}}

" DECTOR:
" break down the cycle reference of vertex node
function! class#graph#dector(this) abort "{{{
    for l:vertex in a:this.vertex
        unlet! l:vertex.edge
    endfor
endfunction "}}}

" ISOBJECT:
function! class#graph#isobject(that) abort "{{{
    return s:class._isobject_(a:that)
endfunction "}}}

" Init: build graph structure from matrix
" a:1, option dict, key accepted:
"    vertex => n, number of vertex, matrix is n*n
"    edge   => m, mumber of edge, matrix is m*3
"    direct => b, edge has direction, default ture
"                 if set false, the vertex or edge matrix can be half size
function! s:class.Init(matrix, ...) dict abort "{{{
    if !empty(self.vertex)
        : WLOG 'this grap has been inited'
        return self
    endif

    if a:0 < 1 || empty(a:1)
        if len(a:matrix) == len(a:matrix[0])
            return self.FromVertexMatrix(a:matrix, {})
        elseif len(a:matrix[0]) == 3
            return self.FromEdgeMatrix(a:matrix, {})
        else
            : ELOG 'init graph require vertex matrix(n*n) or edge matrix(m*3)'
            return self
        endif
    else
        let l:dOption = a:1
        if has_key(l:dOption, 'vertex')
            return self.FromVertexMatrix(a:matrix, l:dOption)
        elseif has_key(l:dOption, 'edge')
            return self.FromEdgeMatrix(a:matrix, l:dOption)
        else
            : ELOG 'init graph option require vertex or edge key'
            return self
        endif
    endif
endfunction "}}}

" FromVertexMatrix: 
" v(i, j) = w means has a edge from vertex i to vertex j, with weight w
" w = 0 means has no edge
" if option['direct'] is false, matrix *maybe* top-right half triangle
" vertex id is made of index [1, vertex-count]
function! s:class.FromVertexMatrix(matrix, option) dict abort "{{{
    let l:bDirect = get(a:option, 'direct', v:true)
    let l:iVertexCnt = get(a:option, 'vertex', 0)
    if l:iVertexCnt == 0
        let l:iVertexCnt = len(a:matrix)
    else
        if l:iVertexCnt != len(a:matrix)
            : ELOG 'the number of vertex dismath'
            return self
        endif
    endif

    for l:iVertexID in range(1, l:iVertexCnt)
        let l:dVertex = class#graph#node#new(l:iVertexID)
        call self.AddVertex(l:dVertex)
    endfor

    for l:row in range(l:iVertexCnt)
        let l:dVertexOut = self.vertex[l:row]
        for l:col in range(l:iVertexCnt)
            let l:iWeight = a:matrix[l:row][l:col]
            if l:iWeight != 0
                let l:dVertexIn = self.vertex[l:col]
                call self.AddEdge(l:dVertexOut, l:dVertexIn, l:iWeight)
                if !l:bDirect && a:matrix[l:col][l:row] == 0
                    call self.AddEdge(l:dVertexIn, l:dVertexOut, l:iWeight)
                endif
            endif
        endfor
    endfor

    return self
endfunction "}}}

" FromEdgeMatrix: 
" each row in matrix is 3-tunple: [vertex-out, vertex-in, weight]
" the first two value is vertex id, not index in graph
" if option['direct'] is false, matrix *muse be* half size
function! s:class.FromEdgeMatrix(matrix, option) dict abort "{{{
    let l:bDirect = get(a:option, 'direct', v:true)
    for l:item in a:matrix
        let l:idVertexOut = l:item[0]
        let l:idVertexIn = l:item[1]
        let l:iWeight = l:item[2]

        if !has_key(self.hashid_, l:idVertexOut)
            let l:dVertex = class#graph#node#new(l:idVertexOut)
            call self.AddVertex(l:dVertex)
        endif
        if !has_key(self.hashid_, l:idVertexIn)
            let l:dVertex = class#graph#node#new(l:idVertexIn)
            call self.AddVertex(l:dVertex)
        endif

        call self.ConnectEdge(l:idVertexOut, l:idVertexIn, l:iWeight)
        if !l:bDirect
            call self.ConnectEdge(l:idVertexIn, l:idVertexOut, l:iWeight)
        endif
    endfor

    return self
endfunction "}}}

" AddVertex: 
" a:dVertex.id can auto-increace, or explict given by user(guard no repeat)
" explict given id maybe string
function! s:class.AddVertex(dVertex, ...) dict abort "{{{
    if empty(a:dVertex.id)
        let self.autoid_ += 1
        let a:dVertex.id = self.autoid_
    else
        " let self.autoid_ = a:dVertex.id
    endif

    if has_key(self.hashid_, a:dVertex.id)
        : ELOG 'repeated vertex id'
        return self
    endif

    let self.hashid_[a:dVertex.id] = a:dVertex
    call add(self.vertex, a:dVertex)
    return self
endfunction "}}}

" NewVertex: 
function! s:class.NewVertex(idVertex) dict abort "{{{
    let l:dVertex = class#graph#node#new(a:idVertex)
    return self.AddVertex(l:dVertex)
endfunction "}}}

" RemoveVertex: 
function! s:class.RemoveVertex(dVertex) dict abort "{{{
    for l:index in range(len(self.vertex))
        let l:vertex = self.vertex[l:index]
        if l:vertex is a:dVertex
            call remove(self.vertex, l:index)
            unlet! self.hashid_[l:vertex.id]
            return self
        endif
    endfor
    :WLOG 'the vertex isnot in graph, something wrong?'
    return self
endfunction "}}}

" GetVertexByID: 
function! s:class.GetVertexByID(id) dict abort "{{{
    if has_key(self, 'hashid_') && !empty(self.hashid_)
        return self.hashid_[a:id]
    endif
    if empty(a:id)
        return {}
    endif
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

" AddEdge: add an edge from a:dVertexOut to a:dVertexIn
" the vertex object must be already in self.vertex list(not check)
" a:1, default weight 1
function! s:class.AddEdge(dVertexOut, dVertexIn, ...) dict abort "{{{
    if a:dVertexOut is a:dVertexIn
        : ELOG 'normal graph can have edge to vertex itself'
        return self
    endif
    let l:iWeight = get(a:000, 0, 1)
    let l:dEdge = class#graph#edge#new(a:dVertexOut, a:dVertexIn, l:iWeight)
    call add(a:dVertexOut.edge, l:dEdge)
    return self
endfunction "}}}

" ConnectEdge: add an edge by vertex id
function! s:class.ConnectEdge(idVertexOut, idVertexIn, ...) dict abort "{{{
    if a:idVertexOut ==# a:idVertexIn
        : ELOG 'normal graph can have edge to vertex itself'
        return self
    endif

    let l:dVertexOut = self.GetVertexByID(a:idVertexOut)
    let l:dVertexIn = self.GetVertexByID(a:idVertexIn)
    let l:iWeight = get(a:000, 0, 1)
    let l:dEdge = class#graph#edge#new(l:dVertexOut, l:dVertexIn, l:iWeight)
    call add(dVertexOut.edge, l:dEdge)
    return self
endfunction "}}}

" EdgeList: 
" a:1, if nonempty, sort by weight, -1 reverse sort
function! s:class.EdgeList(...) dict abort "{{{
    let l:list = []
    for l:vertex in self.vertex
        if !empty(l:vertex.edge)
            call extend(l:list, l:vertex.edge)
        endif
    endfor

    if a:0 > 0
        if !empty(a:1)
            call sort(l:list, function('class#graph#edge#Compare'))
        endif
        if a:1 ==# -1
            call reverse(l:list)
        endif
    endif

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
        let l:sVertex = printf("Vertext: id=%s, %d*Edge\n", l:vertex.id, l:iEdgeCnt)
        for l:edge in l:vertex.edge
            let l:sEdge = printf("  Edge to V[%s], weight[%d]\n", l:edge.to.id, l:edge.weight)
            let l:sVertex .= l:sEdge
        endfor
        call add(l:lsText, l:sVertex)
    endfor

    return join(l:lsText, "\n")
endfunction "}}}

" disp: 
function! s:class.disp() dict abort "{{{
    let l:text = self.string()
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
