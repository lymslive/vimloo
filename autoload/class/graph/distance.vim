" Class: class#graph#distance
" Author: lymslive
" Description: solve distance problem of a graph
" Create: 2017-07-26
" Modify: 2017-08-04

"LOAD:
if exists('s:load') && !exists('g:DEBUG')
    finish
endif

" CLASS:
let s:class = class#old()
let s:class._name_ = 'class#graph#distance'
let s:class._version_ = 1

" refer to the graph in problem
let s:class.graph = {}
" the source vertex id and target vertex id
let s:class.source = 0
let s:class.target = 0

function! class#graph#distance#class() abort "{{{
    return s:class
endfunction "}}}

" NEW:
function! class#graph#distance#new(...) abort "{{{
    if a:0 < 1 || !class#graph#isobject(a:1)
        : ELOG 'expect a graph object'
        return v:none
    endif

    let l:obj = class#new(s:class, a:000)
    return l:obj
endfunction "}}}
" CTOR:
function! class#graph#distance#ctor(this, graph, ...) abort "{{{
    let a:this.graph = a:graph
    if a:0 >= 1
        let a:this.source = a:1
    endif
    if a:0 >= 2
        let a:this.target = a:2
    endif
endfunction "}}}

" ISOBJECT:
function! class#graph#distance#isobject(that) abort "{{{
    return class#isobject(s:class, a:that)
endfunction "}}}

" SetSource: 
function! s:class.SetSource(iSource) dict abort "{{{
    if empty(a:iSource)
        : ELOG 'encounter empty vertex id'
    else
        let self.source = a:iSource
    endif
    return self
endfunction "}}}
" SetTarget: 
function! s:class.SetTarget(iTarget) dict abort "{{{
    if empty(a:iTarget)
        : ELOG 'encounter empty vertex id'
    else
        let self.target = iTarget
    endif
    return self
endfunction "}}}

" a marker data struct injected into each vertex
let s:mark = {}
" distance from the source vertex (-1 means inf max)
let s:mark.dist = -1
" record the previous vertex to rebuild path
let s:mark.prev = {}
" have visited or not
let s:mark.visit = v:false

function! s:SID()
    return matchstr(expand('<sfile>'), '<SNR>\zs\d\+\ze_SID$')
endfun
let s:key = s:SID()
" echo s:key

" Prepare: 
function! s:class.Prepare() dict abort "{{{
    call self.graph.VertexFieldAdd(s:key, s:mark)
endfunction "}}}
" PostClean: 
function! s:class.PostClean() dict abort "{{{
    call self.graph.VertexFieldRmv(s:key)
endfunction "}}}

" CompareDist: 
function! s:CompareDist(vertex1, vertex2) abort "{{{
    return a:vertex1[s:key].dist <= a:vertex2[s:key].dist
endfunction "}}}

" SolveNoWeight: solve the shortest problem with graph of unweight edge
" a:1 source vertex
" a:2 target vertex
" return a dict with key
" 'dist' , the distance from source to target vertex
" 'path' , a list of vertex id
" if target not specified, calculate all distance from source
" need clear result by user
function! s:class.SolveNoWeight(...) dict abort "{{{
    if a:0 >= 1
        let self.source = a:1
    endif
    if a:0 >= 2
        let self.target = a:2
    endif

    let l:vSource = self.graph.GetVertexByID(self.source)
    if empty(l:vSource)
        : ELOG 'invalid source vertex id'
        return {}
    endif
    let l:vTarget = self.graph.GetVertexByID(self.target)

    call self.Prepare()

    let l:vSource[s:key].visit = v:true
    let l:vSource[s:key].dist = 0
    let l:lsVisited = [l:vSource]

    let l:bTargetDone = v:false
    let l:iVertexCnt = len(self.graph.vertex)
    let l:iVisitCnt = 1

    let l:iHead = 0
    while l:iHead < l:iVisitCnt
        let l:vertex = l:lsVisited[l:iHead]
        let l:iDistNew = l:vertex[s:key].dist + 1

        for l:edge in l:vertex.edge
            let l:vertex_to = l:edge.to
            if l:vertex_to[s:key].visit
                continue
            endif

            let l:vertex_to[s:key].visit = v:true
            let l:vertex_to[s:key].prev = l:vertex
            let l:vertex_to[s:key].dist = l:iDistNew
            call add(l:lsVisited, l:vertex_to)
            let l:iVisitCnt += 1

            if l:vertex_to is# l:vTarget
                let l:bTargetDone = v:true
                break
            endif
        endfor

        if l:bTargetDone
            break
        endif

        if l:iVisitCnt >= l:iVertexCnt
            break
        endif

        let l:iHead += 1
    endwhile

    if empty(l:vTarget)
        return {}
    else
        return self.GetResult(l:vTarget)
    endif
endfunction "}}}

" SolveWeighted: Dijkstra's algorithm on solving graph with weighted edge
" input & output like SolveNoWeight()
function! s:class.SolveWeighted(...) dict abort "{{{
    if a:0 >= 1
        let self.source = a:1
    endif
    if a:0 >= 2
        let self.target = a:2
    endif

    let l:vSource = self.graph.GetVertexByID(self.source)
    if empty(l:vSource)
        : ELOG 'invalid source vertex id'
        return {}
    endif
    let l:vTarget = self.graph.GetVertexByID(self.target)

    call self.Prepare()

    let l:vSource[s:key].visit = v:true
    let l:vSource[s:key].dist = 0

    let l:bTargetDone = v:false

    let l:jVertexHeap = class#heap#binary#new('idx_heap_', function('s:CompareDist'))
    call l:jVertexHeap.push(l:vSource)

    while !l:jVertexHeap.empty()
        let l:vertex = l:jVertexHeap.pop()

        for l:edge in l:vertex.edge
            let l:iWeight = l:edge.weight
            let l:iDistNew = l:vertex[s:key].dist + l:iWeight

            let l:vertex_to = l:edge.to
            if l:vertex_to[s:key].visit
                continue
            endif

            if l:vertex_to[s:key].dist < 0
                let l:vertex_to[s:key].dist = l:iDistNew
                let l:vertex_to[s:key].prev = l:vertex
                call l:jVertexHeap.push(l:vertex_to)
            elseif  l:vertex_to[s:key].dist > l:iDistNew
                let l:vertex_to[s:key].dist = l:iDistNew
                let l:vertex_to[s:key].prev = l:vertex
                call l:jVertexHeap.decrease(l:vertex_to)
            endif

        endfor

        let l:vertex[s:key].visit = v:true
        if l:vertex is# l:vTarget
            let l:bTargetDone = v:true
            break
        endif
    endwhile

    if empty(l:vTarget)
        return {}
    else
        return self.GetResult(l:vTarget)
    endif
endfunction "}}}

" GetResult: 
" return the resulted dictionay, with shortest distance and path
" clean the marker injection to the grap vertex after fetch result
" a:1, build path, default true
function! s:class.GetResult(vTarget, ...) dict abort "{{{
    let l:vTarget = a:vTarget
    let l:bBuildPath = get(a:000, 0, 1)

    let l:dRet = {}
    if !l:vTarget[s:key].visit
        : ELOG 'something wrong, cannot solve shortest path problem'
    else
        let l:dRet.dist = l:vTarget[s:key].dist
        if l:bBuildPath
            let l:path = [l:vTarget.id]
            let l:vPrev = l:vTarget[s:key].prev
            while !empty(l:vPrev)
                call add(l:path, l:vPrev.id)
                let l:vPrev = l:vPrev[s:key].prev
            endwhile
            let l:dRet.path = reverse(l:path)
        endif
    endif

    call self.PostClean()
    return dRet
endfunction "}}}

" CleanResult: 
function! s:class.CleanResult() dict abort "{{{
    call self.PostClean()
endfunction "}}}

" SequenTravel: find min path from one vertex to another in sequence
" a:lsVertex, list of vertex id, the first is source, and then each target
" a:bWeight, the graph edge is weighted or not
function! s:class.SequenTravel(lsVertex, bWeight) dict abort "{{{
    let l:dTotal = {'dist': 0, 'path': []}

    let l:index = 0
    let l:iEnd = len(a:lsVertex)
    while l:index + 1 < l:iEnd
        let l:iSource = a:lsVertex[l:index]
        let l:iTarget = a:lsVertex[l:index+1]
        let l:dRet = {}
        if a:bWeight
            let l:dRet = self.SolveWeighted(l:iSource, l:iTarget)
        else
            let l:dRet = self.SolveNoWeight(l:iSource, l:iTarget)
        endif
        if !empty(l:dRet)
            let l:dTotal.dist += l:dRet.dist
            if empty(l:dTotal.path)
                let l:dTotal.path = l:dRet.path
            else
                call extend(l:dTotal.path, l:dRet.path[1:])
            endif
        endif
        let l:index += 1
    endwhile

    return l:dTotal
endfunction "}}}

" ConnetedGraph: 
" build a sub full-connected grap from a subset of vertex,
" the edges is min distance between each other.
" a:lsVertex, list of vertex id of base graph
" a:bWeight, the base graph edge is weighted or not
" return, the new graph built
function! s:class.ConnetedGraph(lsVertex, bWeight) dict abort "{{{
    let l:iEnd = len(a:lsVertex)
    let l:matDist = []

    for i in range(l:iEnd)
        let l:row = repeat([0], l:iEnd)
        call add(l:matDist, l:row)

        let l:iSource = a:lsVertex[i]
        if a:bWeight
            call self.SolveWeighted(l:iSource)
        else
            call self.SolveNoWeight(l:iSource)
        endif

        for j in range(l:iEnd)
            let l:iTarget = a:lsVertex[j]
            let l:vTarget = self.graph.GetVertexByID(l:iTarget)
            let l:matDist[i][j] = l:vTarget[s:key].dist
        endfor
    endfor

    let l:subGraph = class#graph#new()
    let l:option = {'vertex': l:iEnd, 'id': a:lsVertex}
    call l:subGraph.Init(l:matDist, l:option)

    return l:subGraph
endfunction "}}}

" LOAD:
let s:load = 1
:DLOG '-1 class#graph#distance is loading ...'
function! class#graph#distance#load(...) abort "{{{
    if a:0 > 0 && !empty(a:1) && exists('s:load')
        unlet s:load
        return 0
    endif
    return s:load
endfunction "}}}

" TEST:
function! class#graph#distance#test(...) abort "{{{
    return 0
endfunction "}}}
