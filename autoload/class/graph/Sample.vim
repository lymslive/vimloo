" File: Sample
" Author: lymslive
" Description: some graph for test & debug use
" Create: 2017-07-28
" Modify: 2017-08-01

" https://en.wikipedia.org/wiki/Dijkstra%27s_algorithm
let s:matVertex = [
            \ [ 0,  7,  9,  0,  0, 14],
            \ [ 7,  0, 10, 15,  0,  0],
            \ [ 9, 10,  0, 11,  0,  2],
            \ [ 0, 15, 11,  0,  6,  0],
            \ [ 0,  0,  0,  6,  0,  9],
            \ [14,  0,  2,  0,  9,  0]
            \ ]
" size: 6*6 = 36

let s:matEdge = [
            \ [1, 2,  7],
            \ [1, 3,  9],
            \ [1, 6, 14],
            \ [2, 3, 10],
            \ [2, 4, 15],
            \ [3, 4, 11],
            \ [3, 6,  2],
            \ [4, 5,  6],
            \ [5, 6,  9],
            \ ]
" size: 9*3 = 27 / 54

" InputFromVertex: 
function! s:InputFromVertex() abort "{{{
    let l:graph = class#graph#new()
    call l:graph.Init(s:matVertex)
    call l:graph.disp()

    let l:mspant = class#graph#mspant#new(l:graph)
    call l:mspant.Kruskal()
    call l:mspant.disp()

    call class#delete(l:graph)
endfunction "}}}

" InputFromEdge: 
function! s:InputFromEdge() abort "{{{
    let l:graph = class#graph#new()
    call l:graph.Init(s:matEdge, {'edge': 9, 'direct': 0})
    call l:graph.disp()
    let l:jDist = class#graph#distance#new(l:graph)
    let l:dRet = l:jDist.SolveWeighted(1, 5)
    echo l:dRet
    call class#delete(l:graph)
endfunction "}}}

" TEST:
function! class#graph#Sample#test(...) abort "{{{
    " call s:InputFromVertex()
    call s:InputFromEdge()
    return 0
endfunction "}}}
