" Class: class#graph#edge
" Author: lymslive
" Description: edge object of a graph
" Create: 2017-07-12
" Modify: 2017-08-01

"LOAD:
if exists('s:load') && !exists('g:DEBUG')
    finish
endif

" CLASS:
" used as inner struct of graph, not based on class but bare dict
let s:class = {}
let s:class.from = {}
let s:class.to = {}
let s:class.weight = 1

function! class#graph#edge#class() abort "{{{
    return s:class
endfunction "}}}

" NEW: #new(from, to, [weight, data])
function! class#graph#edge#new(from, to, ...) abort "{{{
    let l:obj = copy(s:class)
    let l:obj.from = a:from
    let l:obj.to = a:to

    if a:0 >= 1
        let l:obj.weight = a:1
    else
        let l:obj.weight = 1
    endif
    return l:obj
endfunction "}}}

" Compare: 
function! class#graph#edge#Compare(first, second) abort "{{{
    return a:first.weight - a:second.weight
endfunction "}}}

" LOAD:
let s:load = 1
:DLOG '-1 class#graph#edge is loading ...'
function! class#graph#edge#load(...) abort "{{{
    if a:0 > 0 && !empty(a:1) && exists('s:load')
        unlet s:load
        return 0
    endif
    return s:load
endfunction "}}}

" TEST:
function! class#graph#edge#test(...) abort "{{{
    return 0
endfunction "}}}
