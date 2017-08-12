" Class: class#graph#travel
" Author: lymslive
" Description: travel problem in full complete graph
" Refer: https://en.wikipedia.org/wiki/Travelling_salesman_problem
" Create: 2017-08-02
" Modify: 2017-08-04

"LOAD:
if exists('s:load') && !exists('g:DEBUG')
    finish
endif

" CLASS:
let s:class = class#old()
let s:class._name_ = 'class#graph#travel'
let s:class._version_ = 1

let s:class.graph = {}

function! class#graph#travel#class() abort "{{{
    return s:class
endfunction "}}}

" NEW:
function! class#graph#travel#new(...) abort "{{{
    if a:0 < 1 || !class#graph#isobject(a:1)
        : ELOG '[#graph#travel] expect a graph object'
        return v:none
    endif
    let l:obj = class#new(s:class, a:000)
    return l:obj
endfunction "}}}
" CTOR:
function! class#graph#travel#ctor(this, graph) abort "{{{
    let a:this.graph = a:graph
endfunction "}}}

" ISOBJECT:
function! class#graph#travel#isobject(that) abort "{{{
    return class#isobject(s:class, a:that)
endfunction "}}}

" LowBound: 
" the low bound is min span tree
function! s:class.LowBound() dict abort "{{{
    let l:span = class#graph#mspant#new(self.graph)
    let l:lsEdge = l:span.Kruskal()
    let l:iSum = 0
    for l:edge in l:lsEdge
        let l:iSum += l:edge.weight
    endfor
    return l:iSum
endfunction "}}}

" Greedy: a valid path by greedy algorithm
" a:1, also return path, otherwise only return distance
function! s:class.Greedy(...) dict abort "{{{
    let l:iSum = 0
    let l:idPath = []

    let l:iVertexCnt = len(self.graph.vertex)
    let l:jVertex = self.graph.vertex[0]
    let l:jVertex.visit_ = v:true
    let l:iVisitCnt = 1
    call add(l:idPath, l:jVertex.id)

    while l:iVisitCnt < l:iVertexCnt
        if empty(l:jVertex.edge)
            break
        endif

        let l:jNext = {}
        let l:iMin = -1
        for l:edge in l:jVertex.edge
            if get(l:edge.to, 'visit_', v:false)
                continue
            endif

            if (l:iMin < 0 || l:edge.weight < l:iMin) && l:edge.weight > 0
                let l:jNext = l:edge.to
                let l:iMin = l:edge.weight
            endif
        endfor

        if !empty(l:jNext)
            let l:iSum += l:iMin
            let l:jNext.visit_ = v:true
            let l:iVisitCnt += 1
            call add(l:idPath, l:jVertex.id)
            let l:jVertex = l:jNext
        else
            break
        endif
    endwhile

    for l:jVertex in self.graph.vertex
        unlet! l:jVertex.visit_
    endfor

    if l:iVisitCnt != l:iVertexCnt
        : ELOG '[class#graph#travel.Greedy] ' . 'graph may not full complete'
        return -1
    endif

    if a:0 > 0 && !empty(a:1)
        return {'dist': l:iSum, 'path': l:idPath}
    else
        return l:iSum
    endif
endfunction "}}}

" LOAD:
let s:load = 1
:DLOG '-1 class#graph#travel is loading ...'
function! class#graph#travel#load(...) abort "{{{
    if a:0 > 0 && !empty(a:1) && exists('s:load')
        unlet s:load
        return 0
    endif
    return s:load
endfunction "}}}

" TEST:
function! class#graph#travel#test(...) abort "{{{
    return 0
endfunction "}}}
