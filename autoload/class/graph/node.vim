" Class: class#graph#node
" Author: lymslive
" Description: the vertex node of a graph
" Create: 2017-07-12
" Modify: 2017-07-28

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
